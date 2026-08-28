#ifndef NETWORKMANAGER_H
#define NETWORKMANAGER_H

#include <QObject>
#include <QJsonObject>
#include <QPointer>
#include <QTcpServer>
#include <QTcpSocket>
#include <QUdpSocket>
#include <QTimer>
#include <QVariantMap>

#include "playersmodel.h"

class NetworkManager : public QObject
{
    Q_OBJECT

    Q_PROPERTY(
        QString playerName
            READ playerName
                WRITE setPlayerName
                    NOTIFY playerNameChanged
        )

    Q_PROPERTY(
        PlayersModel *playersModel
            READ playersModel
                CONSTANT
        )

    Q_PROPERTY(
        bool connected
            READ isConnected
                NOTIFY connectedChanged
        )

public:
    explicit NetworkManager(
        QObject *parent = nullptr
        );

    QString playerName() const;
    void setPlayerName(const QString &name);

    Q_INVOKABLE QString enemyName() const;
    void setEnemyName(const QString name);

    PlayersModel *playersModel();

    bool isConnected() const;

    Q_INVOKABLE void startDiscovery();
    Q_INVOKABLE void stopDiscovery();

    Q_INVOKABLE void connectToPlayer(int index);

    Q_INVOKABLE void acceptConnection();
    Q_INVOKABLE void rejectConnection();

    Q_INVOKABLE void disconnectFromPlayer();

    Q_INVOKABLE void sendGameAction(
        const QString &action,
        const QVariantMap &data
        );

    Q_INVOKABLE QString deviceId() const;

    Q_INVOKABLE void resetNetworkState();

signals:
    void playerNameChanged();
    void connectedChanged();

    void connectionRequestReceived(
        const QString &playerName
        );

    void connectionRejected(
        const QString &reason
        );

    void gameActionReceived(
        const QString &action,
        const QVariantMap &data
        );

    void networkError(
        const QString &message
        );

    void opponentDisconnected();

private slots:
    void readPendingDatagrams();
    void sendAnnouncement();

    void onNewConnection();
    void onSocketReadyRead();
    void onSocketDisconnected();

    void onSocketError(
        QAbstractSocket::SocketError error
        );

private:
    void startTcpServer();

    void sendJson(
        const QJsonObject &object
        );

    void processJson(
        const QJsonObject &object
        );

    void setConnected(bool value);
    void closeCurrentSocket(bool notifyOpponent = false);;

private:
    QString m_playerName;
    QString m_deviceId;

    QUdpSocket m_udpSocket;
    QTcpServer m_tcpServer;
    QPointer<QTcpSocket> m_tcpSocket;

    QTimer m_announceTimer;
    QTimer m_playersCleanupTimer;

    PlayersModel m_playersModel;

    QString m_pendingRemoteName;

    QString m_enemyName;

    bool m_connected = false;
};

#endif // NETWORKMANAGER_H
