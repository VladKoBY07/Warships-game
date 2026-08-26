#include "networkmanager.h"
#include "networkprotocol.h"

#include <QAbstractSocket>
#include <QDateTime>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkDatagram>
#include <QUuid>


NetworkManager::NetworkManager(QObject *parent)
    : QObject(parent)
{
    m_deviceId = QUuid::createUuid().toString(
        QUuid::WithoutBraces
        );

    connect(
        &m_udpSocket,
        &QUdpSocket::readyRead,
        this,
        &NetworkManager::readPendingDatagrams
        );

    connect(
        &m_tcpServer,
        &QTcpServer::newConnection,
        this,
        &NetworkManager::onNewConnection
        );

    connect(
        &m_announceTimer,
        &QTimer::timeout,
        this,
        &NetworkManager::sendAnnouncement
        );

    connect(
        &m_playersCleanupTimer,
        &QTimer::timeout,
        this,
        [this]() {
            // Здесь позже можно удалить игроков,
            // которые давно не отправляли announce.
        }
        );
}


QString NetworkManager::playerName() const
{
    return m_playerName;
}


void NetworkManager::setPlayerName(const QString &name)
{
    const QString trimmedName = name.trimmed();

    if (m_playerName == trimmedName)
        return;

    m_playerName = trimmedName;

    emit playerNameChanged();
}

QString NetworkManager::enemyName() const{
    return m_enemyName;
}

void NetworkManager::setEnemyName(const QString &name){
    const QString trimmedName = name.trimmed();

    if(m_enemyName == trimmedName)
        return;

    m_enemyName = trimmedName;
}


PlayersModel *NetworkManager::playersModel()
{
    return &m_playersModel;
}


bool NetworkManager::isConnected() const
{
    return m_connected;
}


void NetworkManager::startDiscovery()
{
    if (m_playerName.isEmpty()) {
        emit networkError(
            QStringLiteral("Сначала укажите имя игрока")
            );
        return;
    }

    startTcpServer();

    if (!m_tcpServer.isListening()) {
        emit networkError(
            QStringLiteral(
                "TCP-сервер не запущен. Обнаружение остановлено."
                )
            );
        return;
    }

    if (m_udpSocket.state()
        != QAbstractSocket::BoundState) {

        const bool success = m_udpSocket.bind(
            QHostAddress::AnyIPv4,
            NetworkProtocol::UdpPort,
            QUdpSocket::ShareAddress
                | QUdpSocket::ReuseAddressHint
            );

        if (!success) {
            emit networkError(
                QStringLiteral(
                    "Не удалось открыть UDP-порт: "
                    )
                + m_udpSocket.errorString()
                );
            return;
        }
    }

    m_announceTimer.start(1000);
    m_playersCleanupTimer.start(3000);

    sendAnnouncement();
}


void NetworkManager::stopDiscovery()
{
    m_announceTimer.stop();
    m_playersCleanupTimer.stop();

    if (m_udpSocket.state()
        == QAbstractSocket::BoundState) {
        m_udpSocket.close();
    }

    m_playersModel.clear();
}


void NetworkManager::startTcpServer()
{
    if (m_tcpServer.isListening())
        return;

    const bool success = m_tcpServer.listen(
        QHostAddress::AnyIPv4,
        NetworkProtocol::TcpPort
        );

    if (!success) {
        emit networkError(
            QStringLiteral(
                "Не удалось открыть TCP-порт: "
                )
            + m_tcpServer.errorString()
            );
    }
}


void NetworkManager::sendAnnouncement()
{
    if (m_playerName.isEmpty())
        return;

    if (m_udpSocket.state()
        != QAbstractSocket::BoundState) {
        return;
    }

    QJsonObject object;

    object["type"] =
        NetworkProtocol::PlayerAnnounce;

    object["protocol"] =
        NetworkProtocol::Version;

    object["game"] =
        NetworkProtocol::GameName;

    object["id"] =
        m_deviceId;

    object["name"] =
        m_playerName;

    object["port"] =
        static_cast<int>(
            NetworkProtocol::TcpPort
            );

    object["timestamp"] =
        QDateTime::currentMSecsSinceEpoch();

    const QByteArray data =
        QJsonDocument(object).toJson(
            QJsonDocument::Compact
            );

    const qint64 bytesWritten =
        m_udpSocket.writeDatagram(
            data,
            QHostAddress::Broadcast,
            NetworkProtocol::UdpPort
            );

    if (bytesWritten < 0) {
        emit networkError(
            QStringLiteral(
                "Ошибка отправки UDP: "
                )
            + m_udpSocket.errorString()
            );
    }
}


void NetworkManager::readPendingDatagrams()
{
    while (m_udpSocket.hasPendingDatagrams()) {
        const QNetworkDatagram datagram =
            m_udpSocket.receiveDatagram();

        if (datagram.isNull())
            continue;

        const QJsonDocument document =
            QJsonDocument::fromJson(
                datagram.data()
                );

        if (!document.isObject())
            continue;

        const QJsonObject object =
            document.object();

        const QString type =
            object["type"].toString();

        if (type
            != NetworkProtocol::PlayerAnnounce) {
            continue;
        }

        const int protocol =
            object["protocol"].toInt();

        if (protocol
            != NetworkProtocol::Version) {
            continue;
        }

        const QString game =
            object["game"].toString();

        if (game
            != NetworkProtocol::GameName) {
            continue;
        }

        const QString id =
            object["id"].toString();

        const QString name =
            object["name"].toString();

        const int port =
            object["port"].toInt();

        if (id.isEmpty()
            || name.isEmpty()
            || port <= 0
            || port > 65535) {
            continue;
        }

        if (id == m_deviceId)
            continue;

        m_playersModel.addOrUpdatePlayer(
            id,
            name,
            datagram.senderAddress(),
            static_cast<quint16>(port)
            );
    }
}


void NetworkManager::onNewConnection()
{
    while (m_tcpServer.hasPendingConnections()) {
        QTcpSocket *socket =
            m_tcpServer.nextPendingConnection();

        if (!socket)
            continue;

        if (m_tcpSocket) {
            socket->disconnectFromHost();
            socket->deleteLater();
            continue;
        }

        m_tcpSocket = socket;

        connect(
            socket,
            &QTcpSocket::readyRead,
            this,
            &NetworkManager::onSocketReadyRead
            );

        connect(
            socket,
            &QTcpSocket::disconnected,
            this,
            &NetworkManager::onSocketDisconnected
            );

        connect(
            socket,
            &QTcpSocket::errorOccurred,
            this,
            &NetworkManager::onSocketError
            );
    }
}


void NetworkManager::connectToPlayer(int index)
{
    if (index < 0
        || index >= m_playersModel.rowCount()) {
        emit networkError(
            QStringLiteral("Игрок не выбран")
            );
        return;
    }

    if (m_tcpSocket) {
        emit networkError(
            QStringLiteral(
                "Соединение уже существует"
                )
            );
        return;
    }

    const QHostAddress address =
        m_playersModel.addressAt(index);

    const quint16 port =
        m_playersModel.portAt(index);

    if (address.isNull()
        || port == 0) {
        emit networkError(
            QStringLiteral(
                "Некорректный адрес игрока"
                )
            );
        return;
    }

    auto *socket =
        new QTcpSocket(this);

    m_tcpSocket = socket;

    connect(
        socket,
        &QTcpSocket::connected,
        this,
        [this]() {
            QJsonObject request;

            request["type"] =
                NetworkProtocol::ConnectionRequest;

            request["protocol"] =
                NetworkProtocol::Version;

            request["game"] =
                NetworkProtocol::GameName;

            request["id"] =
                m_deviceId;

            request["name"] =
                m_playerName;

            sendJson(request);
        }
        );

    connect(
        socket,
        &QTcpSocket::readyRead,
        this,
        &NetworkManager::onSocketReadyRead
        );

    connect(
        socket,
        &QTcpSocket::disconnected,
        this,
        &NetworkManager::onSocketDisconnected
        );

    connect(
        socket,
        &QTcpSocket::errorOccurred,
        this,
        &NetworkManager::onSocketError
        );

    socket->connectToHost(
        address,
        port
        );
}


void NetworkManager::onSocketReadyRead()
{
    if (!m_tcpSocket)
        return;

    while (m_tcpSocket->canReadLine()) {
        const QByteArray line =
            m_tcpSocket->readLine().trimmed();

        if (line.isEmpty())
            continue;

        const QJsonDocument document =
            QJsonDocument::fromJson(line);

        if (!document.isObject())
            continue;

        processJson(
            document.object()
            );
    }
}


void NetworkManager::processJson(
    const QJsonObject &object
    )
{
    const QString type =
        object["type"].toString();

    const int protocol =
        object["protocol"].toInt();

    if (protocol
        != NetworkProtocol::Version) {
        return;
    }

    if (type
        == NetworkProtocol::ConnectionRequest) {

        const QString remoteName =
            object["name"].toString();

        if (remoteName.isEmpty())
            return;

        m_pendingRemoteName =
            remoteName;

        emit connectionRequestReceived(
            remoteName
            );

        return;
    }

    if (type
        == NetworkProtocol::ConnectionAccepted) {

        m_announceTimer.stop();
        m_playersCleanupTimer.stop();

        const QString remoteName =
            object["name"].toString();

        setEnemyName(remoteName);

        setConnected(true);

        return;
    }

    if (type
        == NetworkProtocol::ConnectionRejected) {

        const QString reason =
            object["reason"].toString(
                QStringLiteral(
                    "Подключение отклонено"
                    )
                );

        emit connectionRejected(reason);

        closeCurrentSocket();

        return;
    }

    if (type
        == "OPPONENT_DISCONNECTED") {
        emit opponentDisconnected();

        closeCurrentSocket(false);

        return;
    }

    if (type
        == NetworkProtocol::GameAction) {

        const QString action =
            object["action"].toString();

        const QVariantMap data =
            object["data"]
                .toObject()
                .toVariantMap();

        emit gameActionReceived(
            action,
            data
            );

        return;
    }
}


void NetworkManager::acceptConnection()
{
    if (!m_tcpSocket)
        return;

    if (m_tcpSocket->state()
        != QAbstractSocket::ConnectedState) {
        return;
    }

    QJsonObject response;

    response["type"] =
        NetworkProtocol::ConnectionAccepted;

    response["protocol"] =
        NetworkProtocol::Version;

    response["game"] =
        NetworkProtocol::GameName;

    response["name"] =
        m_playerName;

    sendJson(response);

    m_announceTimer.stop();
    m_playersCleanupTimer.stop();

    setEnemyName(m_pendingRemoteName);
    m_pendingRemoteName.clear();
    setConnected(true);
}


void NetworkManager::rejectConnection()
{
    if (!m_tcpSocket)
        return;

    QJsonObject response;

    response["type"] =
        NetworkProtocol::ConnectionRejected;

    response["protocol"] =
        NetworkProtocol::Version;

    response["game"] =
        NetworkProtocol::GameName;

    response["reason"] =
        QStringLiteral(
            "Игрок отклонил запрос"
            );

    sendJson(response);

    m_pendingRemoteName.clear();

    m_tcpSocket->disconnectFromHost();
}


void NetworkManager::sendGameAction(
    const QString &action,
    const QVariantMap &data
    )
{
    if (!m_connected
        || !m_tcpSocket) {
        return;
    }

    if (m_tcpSocket->state()
        != QAbstractSocket::ConnectedState) {
        return;
    }

    QJsonObject object;

    object["type"] =
        NetworkProtocol::GameAction;

    object["protocol"] =
        NetworkProtocol::Version;

    object["game"] =
        NetworkProtocol::GameName;

    object["action"] =
        action;

    object["data"] =
        QJsonObject::fromVariantMap(data);

    sendJson(object);
}


void NetworkManager::sendJson(
    const QJsonObject &object
    )
{
    if (!m_tcpSocket)
        return;

    if (m_tcpSocket->state()
        != QAbstractSocket::ConnectedState) {
        return;
    }

    QByteArray data =
        QJsonDocument(object).toJson(
            QJsonDocument::Compact
            );

    data.append('\n');

    const qint64 bytesWritten =
        m_tcpSocket->write(data);

    if (bytesWritten < 0) {
        emit networkError(
            QStringLiteral(
                "Ошибка отправки TCP: "
                )
            + m_tcpSocket->errorString()
            );
    }

    m_tcpSocket->flush();
}


void NetworkManager::disconnectFromPlayer()
{
    qDebug()
    << "cpp: <NetworkManager> "
    << "Игрок закрывает соединение";

    if (m_tcpSocket) {
        QJsonObject object;

        object["type"] =
            "OPPONENT_DISCONNECTED";

        object["protocol"] =
            NetworkProtocol::Version;

        object["game"] =
            NetworkProtocol::GameName;

        sendJson(object);
        setEnemyName("");
        m_tcpSocket->disconnectFromHost();
    }

    m_announceTimer.stop();
    setConnected(false);
}


void NetworkManager::closeCurrentSocket(bool notifyOpponent)
{
    if (notifyOpponent && m_tcpSocket) {
        QJsonObject object;

        object["type"] =
            "OPPONENT_DISCONNECTED";

        object["protocol"] =
            NetworkProtocol::Version;

        object["game"] =
            NetworkProtocol::GameName;

        sendJson(object);
    }

    if (m_tcpSocket) {
        QTcpSocket *socket =
            m_tcpSocket.data();

        m_tcpSocket.clear();

        socket->abort();
        socket->deleteLater();
    }

    m_pendingRemoteName.clear();

    setConnected(false);
}


void NetworkManager::onSocketDisconnected()
{
    qDebug()
    << "cpp: <NetworkManager> "
    << "TCP-соединение закрыто";

    if (m_connected) {
        emit opponentDisconnected();
    }

    m_pendingRemoteName.clear();

    if (m_tcpSocket) {
        QTcpSocket *socket =
            m_tcpSocket.data();

        m_tcpSocket.clear();

        socket->deleteLater();
    }
    setEnemyName("");
    setConnected(false);
}

void NetworkManager::onSocketError(
    QAbstractSocket::SocketError error
    )
{
    Q_UNUSED(error)

    if (!m_tcpSocket)
        return;

    const QString message =
        m_tcpSocket->errorString();

    emit networkError(message);

    closeCurrentSocket();
}


void NetworkManager::setConnected(
    bool value
    )
{
    if (m_connected == value)
        return;

    m_connected = value;
    emit connectedChanged();
}
