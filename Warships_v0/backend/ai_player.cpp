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
    std::mt19937 rng(static_cast<unsigned int>(std::time(nullptr)));

    //Ищем, есть ли на поле Damaged
    for (int row = 0; row < GameBoard::BoardSize; ++row) {
        for (int col = 0; col < GameBoard::BoardSize; ++col) {
            if (aiBoard.e_cells[row][col] == GameBoard::cellStatus::Damaged) {

                // Раненная клетка найдена. Проверяем 4 направления вокруг неё (крестом)
                int dx[] = {0, 0, -1, 1};
                int dy[] = {-1, 1, 0, 0};

                for (int i = 0; i < 4; ++i) {
                    int nx = col + dx[i];
                    int ny = row + dy[i];

                    // Если точка внутри поля и Clean — бьем
                    if (nx >= 0 && nx < 10 && ny >= 0 && ny < 10) {
                        if (aiBoard.e_cells[ny][nx] == GameBoard::cellStatus::Clean) {
                            x = nx;
                            y = ny;
                            return; // Нашли цель для добивания — выходим
                        }
                    }
                }
            }
        }
    }

    //Если Damaged нет, ищем случайную пустую клетку
    // Чтобы процессор не гадал в цикле while, соберем все доступные чистые клетки
    std::vector<std::pair<int, int>> cleanCells;
    for (int row = 0; row < GameBoard::BoardSize; ++row) {
        for (int col = 0; col < GameBoard::BoardSize; ++col) {
            if (aiBoard.e_cells[row][col] == GameBoard::cellStatus::Clean) {
                cleanCells.push_back({col, row});
            }
        }
    }

    // Берем случайную из гарантированно пустых
    if (!cleanCells.empty()) {
        std::uniform_int_distribution<int> dist(0, cleanCells.size() - 1);
        auto target = cleanCells[dist(rng)];
        x = target.first;
        y = target.second;
    } else {
        x = 0; y = 0; // На всякий случай, если поле полностью заполнено
    }
}

void ai_player::performAttack()
{
    int targetX, targetY;
    calculateShoot(targetX, targetY);

    // Пока Miss = 0, чтобы код компилировался.
    int gameResponse = 0;

    aiBoard.registerEnemyAnswer(targetX, targetY, gameResponse);

    // Если мы убили корабль человека, автоматически обведем его Shot
    if (aiBoard.e_cells[targetY][targetX] == GameBoard::cellStatus::Killed) {
        for (int row = 0; row < GameBoard::BoardSize; ++row) {
            for (int col = 0; col < GameBoard::BoardSize; ++col) {
                if (aiBoard.e_cells[row][col] == GameBoard::cellStatus::Killed) {

                    // Ставим Shot в 8 клетках вокруг каждой уничтоженной палубы
                    for (int dy = -1; dy <= 1; ++dy) {
                        for (int dx = -1; dx <= 1; ++dx) {
                            int nx = col + dx;
                            int ny = row + dy;

                            if (nx >= 0 && nx < 10 && ny >= 0 && ny < 10) {
                                if (aiBoard.e_cells[ny][nx] == GameBoard::cellStatus::Clean) {
                                    aiBoard.registerEnemyAnswer(nx, ny, 0);
                                }
                            }
                        }
                    }

                }
            }
        }
    }
}