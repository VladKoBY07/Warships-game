#include "ai_player.h"
#include <random>
#include <ctime>

#include <vector>

ai_player::ai_player(QObject *parent)
    : QObject{parent}
{
}

void ai_player::clearBoard()
{
    for (int row = 0; row < BoardSize; ++row) {
        for (int col = 0; col < BoardSize; ++col) {
            ai_cells[row][col] = false;
        }
    }
}

void ai_player::placeShip(int x, int y, int length, bool horizontal)
{
    if (!canPlaceShip(x, y, length, horizontal))
        return;

    if (horizontal) {
        for (int i = 0; i < length; ++i) {
            ai_cells[y][x + i] = true;
        }
    } else {
        for (int i = 0; i < length; ++i) {
            ai_cells[y + i][x] = true;
        }
    }
}

bool ai_player::canPlaceShip(int x, int y, int length, bool horizontal)
{
    if (x < 0 || y < 0 || x >= BoardSize || y >= BoardSize)
        return false;

    if (horizontal) {
        if (x + length > BoardSize)
            return false;
        for (int i = 0; i < length; ++i) {
            if (ai_cells[y][x + i])
                return false;
        }
    } else {
        if (y + length > BoardSize)
            return false;
        for (int i = 0; i < length; ++i) {
            if (ai_cells[y + i][x])
                return false;
        }
    }
    return true;
}
// Вспомогательная функция для проверки, свободны ли клетки корабля И ОРЕОЛ вокруг него
bool ai_player::isZoneClear(int startX, int startY, int length, bool horizontal)
{
    // Проверяем выход самого корабля за границы поля
    if (horizontal) {
        if (startX + length > BoardSize) return false;
    } else {
        if (startY + length > BoardSize) return false;
    }

    // Определяем границы прямоугольника (корабль + 1 клетка вокруг него во все стороны)
    int minX = std::max(0, startX - 1);
    int minY = std::max(0, startY - 1);
    int maxX = horizontal ? std::min(BoardSize - 1, startX + length) : std::min(BoardSize - 1, startX + 1);
    int maxY = horizontal ? std::min(BoardSize - 1, startY + 1) : std::min(BoardSize - 1, startY + length);

    // В коде GameBoard нет прямого геттера для ячеек, но мы можем использовать canPlaceShip,
    // либо, если мы пишем логику "сверху", нам нужно убедиться, что ни одна клетка в зоне не занята.
    // Так как canPlaceShip(x, y, 1, true) вернет false, если ячейка занята, воспользуемся этим:
    for (int y = minY; y <= maxY; ++y) {
        for (int x = minX; x <= maxX; ++x) {
            // Если в этой точке уже стоит часть другого корабля, canPlaceShip вернет false
            if (!canPlaceShip(x, y, 1, true)) {
                return false;
            }
        }
    }

    return true;
}

void ai_player::generateRandomPlacement()
{

    // Полностью очищаем поле перед новой расстановкой
    clearBoard();

    // Инициализируем генератор случайных чисел
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
            if (isZoneClear(x, y, length, horizontal)) {
                placeShip(x, y, length, horizontal);
                placed = true;
            }
        }
    }
}
