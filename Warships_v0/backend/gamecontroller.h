#ifndef GAMECONTROLLER_H
#define GAMECONTROLLER_H

#include <QObject>
#include "backend/gameboard.h"
#include "backend/ai_player.h"

class GameController : public QObject
{
    Q_OBJECT
public:
    enum Turn{
        MyTurn = 0,
        EnemyTurn = 1,
        GameOver = 2
    };
    Q_ENUM(Turn)

    const int ships_sum = 10; // количество кораблей
    int killed_ships = 0;
    int alive_ships = ships_sum;

    explicit GameController(GameBoard *gameboard, ai_player *ai, QObject *parent = nullptr);

    Q_PROPERTY(Turn turn READ turn NOTIFY turnChanged)
    Turn turn() const { return m_turn; }

    Q_INVOKABLE void playerShootsAt(int x, int y);

    // запуск игры, режимы
    void clearController();
    Q_INVOKABLE void start_PvAI();
    Q_INVOKABLE void start_Local();

signals:
    void turnChanged();

private:
    GameBoard *m_gameboard;
    ai_player *m_ai;

    void setTurn(Turn new_turn);
    Turn m_turn = Turn::MyTurn;
};

#endif // GAMECONTROLLER_H