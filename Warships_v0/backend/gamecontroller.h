#ifndef GAMECONTROLLER_H
#define GAMECONTROLLER_H

#include <QObject>
#include <QString>
#include <QVariantMap>
#include "backend/gameboard.h"
#include "backend/ai_player.h"

class NetworkManager;

class GameController : public QObject
{
    Q_OBJECT
public:
    enum Turn{
        MyTurn = 0,
        EnemyTurn = 1,
        GameOver_PlayerWon = 2,
        GameOver_PlayerLost = 3
    };
    Q_ENUM(Turn)

    enum Gamemodes{
        PvAI = 0,
        Local= 1
    };
    Q_ENUM(Gamemodes)

    const int ships_sum = 10; // количество кораблей
    int killed_ships = 0;
    int alive_ships = ships_sum;

    explicit GameController(GameBoard *gameboard, ai_player *ai, NetworkManager *networkManager, QObject *parent = nullptr);

    Q_PROPERTY(Turn turn READ turn NOTIFY turnChanged)
    Turn turn() const { return m_turn; }

    Q_PROPERTY(Gamemodes gamemode READ gamemode NOTIFY gamemodeChanged)
    Gamemodes gamemode() const { return m_gamemode; }

    Q_PROPERTY(QString playerName READ playerName WRITE setPlayerName NOTIFY playerNameChanged)
    QString playerName() const { return m_playerName; }

    Q_INVOKABLE void playerShootsAt(int x, int y);

    // запуск игры, режимы
    void clearController();
    Q_INVOKABLE void start_PvAI();
    Q_INVOKABLE void start_Local();

signals:
    void turnChanged();
    void gamemodeChanged();
    void playerNameChanged();

    void remoteShotReceived(int x, int y);

private slots:
    void onGameActionReceived(const QString &action, const QVariantMap &data);

private:
    void setTurn(Turn new_turn);
    void setGamemode(Gamemodes new_gamemode);
    void setPlayerName(const QString &name);

    void sendNetworkShot(int x, int y);
    void handleRemoteShot(int x, int y);

private:
    GameBoard *m_gameboard = nullptr;
    ai_player *m_ai = nullptr;
    NetworkManager *m_networkManager = nullptr;

    QString m_playerName;

    Turn m_turn = Turn::MyTurn;
    Gamemodes m_gamemode = Gamemodes::PvAI;
};

#endif // GAMECONTROLLER_H