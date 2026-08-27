#include "gamecontroller.h"
#include "backend/gameboard.h"
#include "backend/ai_player.h"
#include "network/networkmanager.h"
#include <QDebug>

GameController::GameController(GameBoard *gameboard,
                               ai_player *ai,
                               NetworkManager *networkManager,
                               QObject *parent)
    : QObject(parent)
    , m_gameboard(gameboard)
    , m_ai(ai)
    , m_networkManager(networkManager)
{
    if(!m_networkManager)
        return;

    connect(m_networkManager, &NetworkManager::gameActionReceived, this, &GameController::onGameActionReceived);
    connect(m_networkManager, &NetworkManager::opponentDisconnected, this, &GameController::onOpponentDisconnected);
    connect(m_networkManager, &NetworkManager::connectedChanged, this, &GameController::onConnectedChanged);
}

void GameController::setTurn(Turn turn)
{
    if (m_turn == turn)
        return;

    m_turn = turn;
    emit turnChanged();
}

void GameController::setGamemode(Gamemodes new_gamemode)
{
    if (m_gamemode == new_gamemode)
        return;

    m_gamemode = new_gamemode;
    emit gamemodeChanged();
}

void GameController::setPlayerName(const QString &name)
{
    const QString trimmedName = name.trimmed();

    if (m_playerName == trimmedName)
        return;

    m_playerName = trimmedName;
    emit playerNameChanged();
}

bool GameController::opponentReady() const
{
    return m_opponentReady;
}

void GameController::setOpponentReady(bool ready)
{
    if (m_opponentReady == ready)
        return;

    m_opponentReady = ready;

    emit opponentReadyChanged();
}

void GameController::setPlayerReady(bool ready)
{
    if (!m_networkManager)
        return;

    if (m_gamemode != Gamemodes::Local)
        return;

    QVariantMap data;

    data["ready"] = ready;

    m_networkManager->sendGameAction(QStringLiteral("GAME_READY"), data);

    qDebug()
        << "cpp: <Controller> "
        << "Отправлена готовность:"
        << ready;
}

void GameController::clearController()
{
    qDebug()
    << "cpp: <Controller> Очистка игрового состояния";

    if (m_gameboard)
        m_gameboard->clearBoards();

    if (m_ai)
        m_ai->aiBoard.clearBoards();

    killed_ships = 0;
    alive_ships = ships_sum;

    setTurn(Turn::MyTurn);

    setOpponentReady(false);

    // Сброс сетевого подключения
    if (m_networkManager) {
        m_networkManager->resetNetworkState();
        m_networkManager->stopDiscovery();
    }
}

void GameController::start_PvAI(){
    qDebug() << "cpp: <Controller> Запуск одиночной игры";
    // подготовка ии игрока
    clearController();
    m_ai->generateRandomPlacement();

    setGamemode(Gamemodes::PvAI);
    setTurn(Turn::MyTurn);
}

void GameController::start_Local(){
    qDebug() << "cpp: <Controller> Запуск сетевой игры";
    // подготовка игры по сети
    clearController();

    setGamemode(Gamemodes::Local);
}

void GameController::playerShootsAt(int x, int y) // пока только с ии
{
    // Если не ход игрока то ничего
    if (m_turn != Turn::MyTurn)
        return;

    // Если уже бита то ничего
    if (m_gameboard->enemyCellStatusAt(x, y) != static_cast<int>(GameBoard::cellStatus::Clean))
        return;

    switch (static_cast<int>(m_gamemode)) {
    case static_cast<int>(GameController::Gamemodes::PvAI): // если против ии
    {
        // 0 Clean, 1 Ship, 2 Shot, 3 Damaged, 4 Killed
        const int result = m_ai->aiBoard.receiveAttack(x, y);
        m_gameboard->registerEnemyAnswer(x, y, result);
        switch (result) {
        case static_cast<int>(GameBoard::cellStatus::Shot):{ // Miss
            int attack_result = static_cast<int>(GameBoard::cellStatus::Damaged);
            int shot_status = static_cast<int>(GameBoard::cellStatus::Shot);
            int kill_status = static_cast<int>(GameBoard::cellStatus::Killed);
            while(attack_result != shot_status) // пока ии не промажет или победит стреляет
            {
                setTurn(Turn::EnemyTurn);
                int attackX = 0, attackY = 0;
                m_ai->calculateShoot(attackX, attackY);
                attack_result = m_gameboard->receiveAttack(attackX, attackY);
                m_ai->aiBoard.registerEnemyAnswer(attackX, attackY, attack_result);

                if(attack_result == kill_status){
                    alive_ships -= 1;
                    if(alive_ships == 0){
                        setTurn(Turn::GameOver_PlayerLost);
                        break;
                    }
                }
            }
            if (m_turn != Turn::GameOver_PlayerLost) {
                setTurn(Turn::MyTurn);
            }
            break;
        }

        case static_cast<int>(GameBoard::cellStatus::Damaged): // Hit
            setTurn(Turn::MyTurn);
            break;

        case static_cast<int>(GameBoard::cellStatus::Killed): // Kill
            killed_ships++;
            if(killed_ships == ships_sum){ // если добил последнюю клетку то победа
                setTurn(Turn::GameOver_PlayerWon);
            } else{
                setTurn(Turn::MyTurn);
            }
            break;
        }
        break;
    }
    case static_cast<int>(GameController::Gamemodes::Local): // если по сети
    {
        sendNetworkShot(x, y);
        break;
    }
}
}

void GameController::sendNetworkShot(int x, int y){
    if(!m_networkManager)
        return;

    if(!m_networkManager->isConnected()){
        qDebug() << "cpp: <Controller> Нет сетевого подключения";
        return;
    }

    QVariantMap data;
    data["x"] = x;
    data["y"] = y;

    m_networkManager->sendGameAction(QStringLiteral("SHOT"), data);

    setTurn(Turn::EnemyTurn);
    qDebug() << "cpp: <Controller> Отправлен сетевой выстрел: " << x << y;
}

void GameController::onGameActionReceived(const QString &action, const QVariantMap &data)
{
    if (action == "GAME_READY") {
        const bool ready = data.value("ready").toBool();
        setOpponentReady(ready);

        qDebug()
            << "cpp: <Controller> "
            << "Соперник изменил готовность:"
            << ready;

        return;
    }

    if (action == "GAME_START") {
        const QString myId = m_networkManager->deviceId();
        const QString remoteId = data.value("myDeviceId").toString();

        if (myId.isEmpty() || remoteId.isEmpty()) {
            qWarning()
            << "cpp: <Controller> "
            << "Некорректный GAME_START";
            return;
        }

        const bool iAmFirst = (myId > remoteId);

        if (iAmFirst) {
            setTurn(Turn::MyTurn);

            qDebug()
                << "cpp: <Controller> "
                << "Мой ход первым (myId > remoteId)";
        } else {
            setTurn(Turn::EnemyTurn);

            qDebug()
                << "cpp: <Controller> "
                << "Ход соперника первым (myId < remoteId)";
        }

        return;
    }

    if (action == "SHOT") {
        const int x =
            data.value("x").toInt();

        const int y =
            data.value("y").toInt();

        handleRemoteShot(x, y);

        return;
    }

    if (action == "SHOT_RESULT") {
        const int x =
            data.value("x").toInt();

        const int y =
            data.value("y").toInt();

        const int result =
            data.value("result").toInt();

        if (m_gameboard) {
            m_gameboard->registerEnemyAnswer(x, y, result);
        }

        if (result == static_cast<int>(GameBoard::cellStatus::Killed)) {
            killed_ships++;

            if (killed_ships >= ships_sum) {
                setTurn(Turn::GameOver_PlayerWon);
                return;
            }
        }

        if (result == static_cast<int>(GameBoard::cellStatus::Shot)) {
            setTurn(Turn::EnemyTurn);
        } else {
            setTurn(Turn::MyTurn);
        }

        return;
    }
}

void GameController::onOpponentDisconnected()
{
    qDebug()
    << "cpp: <Controller> "
    << "Соперник отключился";

    clearController();

    emit opponentDisconnected();
}

void GameController::handleRemoteShot(int x, int y)
{
    if (!m_gameboard)
        return;

    qDebug() << "cpp: <Controller> Получен выстрел соперника:" << x << y;

    const int result = m_gameboard->receiveAttack(x, y);

    QVariantMap response;

    response["x"] = x;
    response["y"] = y;
    response["result"] = result;

    if (m_networkManager && m_networkManager->isConnected()) {
        m_networkManager->sendGameAction(QStringLiteral("SHOT_RESULT"), response);
    }

    emit remoteShotReceived(x, y);

    if (result == static_cast<int>(GameBoard::cellStatus::Killed)) {
        alive_ships -= 1;

        if (alive_ships <= 0) {
            setTurn(Turn::GameOver_PlayerLost);
            return;
        }
    }

    if (result == static_cast<int>(GameBoard::cellStatus::Shot)){
        setTurn(Turn::MyTurn);
    } else {
        setTurn(Turn::EnemyTurn);
    }
}

void GameController::onConnectedChanged()
{
    if (!m_networkManager)
        return;

    if (!m_networkManager->isConnected())
        return;

    const QString myId = m_networkManager->deviceId();

    QVariantMap data;

    data["myDeviceId"] = myId;

    m_networkManager->sendGameAction(QStringLiteral("GAME_START"), data);

    qDebug()
        << "cpp: <Controller> "
        << "Отправлен GAME_START, deviceId:"
        << myId;
}
