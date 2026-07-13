#include "gamecontroller.h"
#include <QDebug>

GameController::GameController(GameBoard *gameboard,
                               ai_player *ai,
                               QObject *parent)
    : m_gameboard(gameboard), m_ai(ai)
{}

void GameController::setGamemode(int mode)
{
    qDebug() << "<C++> current mode: " << mode;
    if (m_gamemode == mode)
        return;
    m_gamemode = mode;
    emit gamemodeChanged(m_gamemode);
}