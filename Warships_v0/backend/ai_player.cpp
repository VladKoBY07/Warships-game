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
