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

void ai_player::calculateShoot(int& x, int& y)
{
    std::mt19937 rng(static_cast<unsigned int>(std::time(nullptr)));

    //Ищем, есть ли на поле Damaged
    std::vector<std::pair<int, int>> damaged;
    for (int row = 0; row < GameBoard::BoardSize; ++row) {
        for (int col = 0; col < GameBoard::BoardSize; ++col) {
            if (aiBoard.e_cells[row][col] == GameBoard::cellStatus::Damaged) {
                damaged.push_back({col, row}); // {x, y}
            }
        }
    }

    if (!damaged.empty()) {
        std::vector<std::pair<int, int>> targets;

        if (damaged.size() == 1) {
            int cx = damaged[0].first;
            int cy = damaged[0].second;
                // Раненная клетка найдена. Проверяем 4 направления вокруг неё (крестом)
                int dx[] = {0, 0, -1, 1};
                int dy[] = {-1, 1, 0, 0};

                for (int i = 0; i < 4; ++i) {
                    int nx = cx + dx[i];
                    int ny = cy + dy[i];

                    // Если точка внутри поля и Clean — бьем
                    if (nx >= 0 && nx < 10 && ny >= 0 && ny < 10) {
                        if (aiBoard.e_cells[ny][nx] == GameBoard::cellStatus::Clean) {
                            targets.push_back({nx, ny});
                        }
                    }
                }
        }


        else {
            bool isHorizontal = (damaged[0].second == damaged[1].second);

            if (isHorizontal) {
                int minX = damaged[0].first;
                int maxX = damaged[0].first;
                int yLine = damaged[0].second;

                for (const auto& p : damaged) {
                    minX = std::min(minX, p.first);
                    maxX = std::max(maxX, p.first);
                }

                // Проверяем возможность выстрела слева от линии
                if (minX > 0 && aiBoard.e_cells[yLine][minX - 1] == GameBoard::cellStatus::Clean) {
                    targets.push_back({minX - 1, yLine});
                }
                // Проверяем возможность выстрела справа от линии
                if (maxX < 9 && aiBoard.e_cells[yLine][maxX + 1] == GameBoard::cellStatus::Clean) {
                    targets.push_back({maxX + 1, yLine});
                }
            } else {
                int minY = damaged[0].second;
                int maxY = damaged[0].second;
                int xLine = damaged[0].first;

                for (const auto& p : damaged) {
                    minY = std::min(minY, p.second);
                    maxY = std::max(maxY, p.second);
                }

                // Проверяем возможность выстрела сверху от линии
                if (minY > 0 && aiBoard.e_cells[minY - 1][xLine] == GameBoard::cellStatus::Clean) {
                    targets.push_back({xLine, minY - 1});
                }
                // Проверяем возможность выстрела снизу от линии
                if (maxY < 9 && aiBoard.e_cells[maxY + 1][xLine] == GameBoard::cellStatus::Clean) {
                    targets.push_back({xLine, maxY + 1});
                }
            }
        }

        // Если нашли потенциальные цели для продолжения линии — стреляем по одной из них
        if (!targets.empty()) {
            std::uniform_int_distribution<int> dist(0, targets.size() - 1);
            auto target = targets[dist(rng)];
            x = target.first;
            y = target.second;
            return;
        }
    }

    // Если раненых нет (или край линии упирается в края/промахи), ищем случайную пустую клетку
    std::vector<std::pair<int, int>> cleanCells;
    for (int row = 0; row < GameBoard::BoardSize; ++row) {
        for (int col = 0; col < GameBoard::BoardSize; ++col) {
            if (aiBoard.e_cells[row][col] == GameBoard::cellStatus::Clean) {
                cleanCells.push_back({col, row});
            }
        }
    }

    if (!cleanCells.empty()) {
        std::uniform_int_distribution<int> dist(0, cleanCells.size() - 1);
        auto target = cleanCells[dist(rng)];
        x = target.first;
        y = target.second;
    } else {
        x = 0; y = 0;
    }
}