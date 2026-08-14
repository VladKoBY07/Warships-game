#ifndef GAMECONTROLLER_H
#define GAMECONTROLLER_H

#include <QObject>
#include <QString>
#include "backend/gameboard.h"
#include "backend/ai_player.h"

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

    explicit GameController(GameBoard *gameboard, ai_player *ai, QObject *parent = nullptr);

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

private:
    GameBoard *m_gameboard;
    ai_player *m_ai;
    QString m_playerName;

    void setTurn(Turn new_turn);
    Turn m_turn = Turn::MyTurn;
    void setGamemode(Gamemodes new_gamemode);
    Gamemodes m_gamemode = Gamemodes::PvAI;
    void setPlayerName(const QString &name);
};

#endif // GAMECONTROLLER_H