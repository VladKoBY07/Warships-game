#include "gamecontroller.h"
#include <QDebug>

GameController::GameController(GameBoard *gameboard,
                               ai_player *ai,
                               QObject *parent)
    : m_gameboard(gameboard), m_ai(ai)
{}

void GameController::setTurn(Turn turn)
{
    if (m_turn == turn)
        return;

    m_turn = turn;
    emit turnChanged();
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
    killed_ships = 0;
    alive_ships = ships_sum;
    m_ai->generateRandomPlacement();

    setTurn(Turn::MyTurn);
}

void GameController::start_Local(){
    qDebug() << "cpp: <Controller> Запуск сетевой игры";
    // подготовка игры по сети
    killed_ships = 0;
    alive_ships = ships_sum;
    // TODO: сделать подготовку к игре по сети и выбор первого хода
}

void GameController::playerShootsAt(int x, int y) // пока только с ии
{
    // Если не ход игрока то ничего
    if (m_turn != Turn::MyTurn)
        return;

    // Если уже бита то ничего
    if (m_gameboard->enemyCellStatusAt(x, y) != static_cast<int>(GameBoard::cellStatus::Clean))
        return;

    // AI обрабатывает удар по своему полю
    // 0 Clean, 1 Ship, 2 Shot, 3 Damaged, 4 Killed
    const int result = m_ai->receiveAttack(x, y);

    // Записываем результат на поле выстрелов игрока
    m_gameboard->registerEnemyAnswer(x, y, result);

    switch (result) {
    case 2: // Miss
        setTurn(Turn::EnemyTurn);
        break;

    case 3: // Hit
        setTurn(Turn::MyTurn);
        break;

    case 4: // Kill
        killed_ships++;
        if(killed_ships == ships_sum){ // если добил последнюю клетку то победа
            setTurn(Turn::GameOver);
        } else{
            setTurn(Turn::MyTurn);
        }
        break;

    default:
        break;
    }
}