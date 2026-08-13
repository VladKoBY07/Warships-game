#include "gamecontroller.h"
#include <QDebug>

GameController::GameController(GameBoard *gameboard,
                               ai_player *ai,
                               QObject *parent)
    : QObject(parent)
    , m_gameboard(gameboard)
    , m_ai(ai)
{}

void GameController::setTurn(Turn turn)
{
    if (m_turn == turn)
        return;

    m_turn = turn;
    emit turnChanged();
}

void GameController::setGamemode(Gamemodes new_gamemode){
    if (gamemode == new_gamemode)
        return;
    gamemode = new_gamemode;
}

void GameController::clearController(){
    m_gameboard->clearBoards();
    m_ai->aiBoard.clearBoards();
    killed_ships = 0;
    alive_ships = ships_sum;
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
    // TODO: выбор хода
}

void GameController::playerShootsAt(int x, int y) // пока только с ии
{
    // Если не ход игрока то ничего
    if (m_turn != Turn::MyTurn)
        return;

    // Если уже бита то ничего
    if (m_gameboard->enemyCellStatusAt(x, y) != static_cast<int>(GameBoard::cellStatus::Clean))
        return;

    switch (static_cast<int>(gamemode)) {
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
                int attackX, attackY;
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
        break;
    }
}
}