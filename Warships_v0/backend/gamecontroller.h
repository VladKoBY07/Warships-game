#ifndef GAMECONTROLLER_H
#define GAMECONTROLLER_H

#include <QObject>
#include "backend/gameboard.h"
#include "backend/ai_player.h"

class GameController : public QObject
{
    Q_OBJECT
public:
    enum GameMode {
        PvAI_mode = 0,
        Local_mode = 1,
    };
    Q_ENUM(GameMode)

    explicit GameController(GameBoard *gameboard, ai_player *ai, QObject *parent = nullptr);

    Q_PROPERTY(int gamemode READ gamemode WRITE setGamemode NOTIFY gamemodeChanged)

    int gamemode() const { return m_gamemode; }
    void setGamemode(int mode);




signals:
    void gamemodeChanged(int mode);

private:
    int m_gamemode = 0; // по умолчанию
    GameBoard *m_gameboard;
    ai_player *m_ai;
};

#endif // GAMECONTROLLER_H