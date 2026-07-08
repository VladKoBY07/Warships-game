#include "ai_player.h"
#include <random>
#include <ctime>

#include <vector>

ai_player::ai_player(QObject *parent): QObject{parent}{}

void ai_player::generateRandomPlacement()
{
    // Полностью очищаем поле перед новой расстановкой
    aiBoard.clearBoards();

    std::mt19937 rng(static_cast<unsigned int>(std::time(nullptr)));
    std::uniform_int_distribution<int> coordDist(0, 9);
    std::uniform_int_distribution<int> flipDist(0, 1);   // 0 - вертикально, 1 - горизонтально

    std::vector<int> ships = {4, 3, 3, 2, 2, 2, 1, 1, 1, 1};

    // Расставляем каждый корабль
    for (int length : ships) {
        bool placed = false;

        // Пытаемся поставить корабль, пока не найдем валидное место
        while (!placed) {
            int x = coordDist(rng);
            int y = coordDist(rng);
            bool horizontal = flipDist(rng) == 1;

            // Проверяем правила расстановки (границы и соседние клетки)
            if (aiBoard.canPlaceShip(x, y, length, horizontal)) {
                aiBoard.placeShip(x, y, length, horizontal);
                placed = true;
            }
        }
    }
}

int ai_player::receiveAttack(int x, int y)
{// 0 Clean, 1 Ship, 2 Shot, 3 Damaged, 4 Killed
    if (aiBoard.m_cells[x][y] == GameBoard::cellStatus::Ship)
    {
        int rx = x;
        int ry = y;
        //left
        while (rx > 0)
        {
            rx -= 1;
            if (aiBoard.m_cells[rx][y] == GameBoard::cellStatus::Clean ||
                aiBoard.m_cells[rx][y] == GameBoard::cellStatus::Shot)
                break;

            if (aiBoard.m_cells[rx][y] == GameBoard::cellStatus::Ship)
            {
                aiBoard.m_cells[x][y] = GameBoard::cellStatus::Damaged;
                return static_cast<int>(GameBoard::cellStatus::Damaged);
            }
        }
        rx = x;

        //right
        while (rx < 9)
        {
            rx += 1;
            if (aiBoard.m_cells[rx][y] == GameBoard::cellStatus::Clean ||
                aiBoard.m_cells[rx][y] == GameBoard::cellStatus::Shot)
                break;

            if (aiBoard.m_cells[rx][y] == GameBoard::cellStatus::Ship)
            {
                aiBoard.m_cells[x][y] = GameBoard::cellStatus::Damaged;
                return static_cast<int>(GameBoard::cellStatus::Damaged);
            }
        }

        //up
        while (ry > 0)
        {
            ry -= 1;
            if (aiBoard.m_cells[x][ry] == GameBoard::cellStatus::Clean ||
                aiBoard.m_cells[x][ry] == GameBoard::cellStatus::Shot)
                break;

            if (aiBoard.m_cells[x][ry] == GameBoard::cellStatus::Ship)
            {
                aiBoard.m_cells[x][y] = GameBoard::cellStatus::Damaged;
                return static_cast<int>(GameBoard::cellStatus::Damaged);
            }
        }

        ry = y;

        //down
        while (ry < 9)
        {
            ry += 1;
            if (aiBoard.m_cells[x][ry] == GameBoard::cellStatus::Clean ||
                aiBoard.m_cells[x][ry] == GameBoard::cellStatus::Shot)
                break;

            if (aiBoard.m_cells[x][ry] == GameBoard::cellStatus::Ship)
            {
                aiBoard.m_cells[x][y] = GameBoard::cellStatus::Damaged;
                return static_cast<int>(GameBoard::cellStatus::Damaged);
            }
        }

        return static_cast<int>(GameBoard::cellStatus::Killed);
    }
    return static_cast<int>(aiBoard.myCellStatusAt(x, y));
}

void ai_player::calculateShoot(int& x, int& y)
{
    // TODO: Мішаня набацает ходы
    x = 1;
    y = 1;
}

void ai_player::performAttack()
{
    int x, y;
    calculateShoot(x, y);
    // вызов функции у gameboard, запись ответа

}



