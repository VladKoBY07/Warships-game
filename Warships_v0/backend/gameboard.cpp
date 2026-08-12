#include "gameboard.h"

#include <QDebug>
#include <algorithm>

GameBoard::GameBoard(QObject *parent)
    : QObject(parent)
{
    clearBoards();
}

void GameBoard::clearBoards()
{
    for (int row = 0; row < BoardSize; ++row) {
        for (int col = 0; col < BoardSize; ++col) {
            m_cells[row][col] = cellStatus::Clean;
            e_cells[row][col] = cellStatus::Clean;
        }
    }

    notifyBoardChanged();
}

bool GameBoard::canPlaceShip(int x, int y, int length, bool horizontal)
{
    // Проверка длины корабля
    if (length <= 0 || length > BoardSize)
        return false;

    // Проверка начальных координат
    if (x < 0 || y < 0 || x >= BoardSize || y >= BoardSize)
        return false;

    if (horizontal) {
        // Проверка выхода корабля за правую границу
        if (x + length > BoardSize)
            return false;

        // Проверка клеток корабля
        for (int i = 0; i < length; ++i) {
            if (m_cells[y][x + i] != cellStatus::Clean)
                return false;
        }

        // Проверка зоны вокруг горизонтального корабля
        const int startX = std::max(0, x - 1);
        const int endX = std::min(BoardSize - 1, x + length);
        const int startY = std::max(0, y - 1);
        const int endY = std::min(BoardSize - 1, y + 1);

        for (int yy = startY; yy <= endY; ++yy) {
            for (int xx = startX; xx <= endX; ++xx) {
                if (m_cells[yy][xx] != cellStatus::Clean)
                    return false;
            }
        }
    } else {
        // Проверка выхода корабля за нижнюю границу
        if (y + length > BoardSize)
            return false;

        // Проверка клеток корабля
        for (int i = 0; i < length; ++i) {
            if (m_cells[y + i][x] != cellStatus::Clean)
                return false;
        }

        // Проверка зоны вокруг вертикального корабля
        const int startX = std::max(0, x - 1);
        const int endX = std::min(BoardSize - 1, x + 1);
        const int startY = std::max(0, y - 1);
        const int endY = std::min(BoardSize - 1, y + length);

        for (int yy = startY; yy <= endY; ++yy) {
            for (int xx = startX; xx <= endX; ++xx) {
                if (m_cells[yy][xx] != cellStatus::Clean)
                    return false;
            }
        }
    }

    return true;
}

void GameBoard::placeShip(int x, int y, int length, bool horizontal)
{
    if (!canPlaceShip(x, y, length, horizontal))
        return;

    if (horizontal) {
        for (int i = 0; i < length; ++i) {
            m_cells[y][x + i] = cellStatus::Ship;
        }
    } else {
        for (int i = 0; i < length; ++i) {
            m_cells[y + i][x] = cellStatus::Ship;
        }
    }

    notifyBoardChanged();
}

void GameBoard::removeShip(int x, int y, int length, bool horizontal)
{
    bool changed = false;

    if (horizontal) {
        for (int i = 0; i < length; ++i) {
            const int cx = x + i;

            if (cx >= 0 && cx < BoardSize &&
                y >= 0 && y < BoardSize &&
                m_cells[y][cx] != cellStatus::Clean) {

                m_cells[y][cx] = cellStatus::Clean;
                changed = true;
            }
        }
    } else {
        for (int i = 0; i < length; ++i) {
            const int cy = y + i;

            if (x >= 0 && x < BoardSize &&
                cy >= 0 && cy < BoardSize &&
                m_cells[cy][x] != cellStatus::Clean) {

                m_cells[cy][x] = cellStatus::Clean;
                changed = true;
            }
        }
    }

    if (changed)
        notifyBoardChanged();
}

bool GameBoard::cellOccupied(int x, int y) const
{
    if (x < 0 || y < 0 ||
        x >= BoardSize || y >= BoardSize) {
        return false;
    }

    return m_cells[y][x] != cellStatus::Clean;
}

int GameBoard::myCellStatusAt(int x, int y) const
{
    if (x < 0 || y < 0 ||
        x >= BoardSize || y >= BoardSize) {
        return static_cast<int>(cellStatus::Clean);
    }

    return static_cast<int>(m_cells[y][x]);
}

int GameBoard::enemyCellStatusAt(int x, int y) const
{
    if (x < 0 || y < 0 ||
        x >= BoardSize || y >= BoardSize) {
        return static_cast<int>(cellStatus::Clean);
    }

    return static_cast<int>(e_cells[y][x]);
}

void GameBoard::notifyBoardChanged()
{
    ++m_boardRevision;
    emit boardChanged();
}

void GameBoard::registerEnemyAnswer(int x, int y, int result)
{
    if (x < 0 || y < 0 ||
        x >= BoardSize || y >= BoardSize) {
        return;
    }

    cellStatus newStatus;

    switch (result) {
    case static_cast<int>(cellStatus::Shot):
        newStatus = cellStatus::Shot;
        break;

    case static_cast<int>(cellStatus::Damaged):
        newStatus = cellStatus::Damaged;
        break;

    case static_cast<int>(cellStatus::Killed):
        newStatus = cellStatus::Killed;
        break;

    default:
        qWarning() << "Unknown enemy answer:" << result;
        return;
    }

    cellStatus &cell = e_cells[y][x];

    // Если статус уже такой же, поле фактически не изменилось
    if (cell == newStatus)
        return;

    // обозначить корабль при убийстве
    if(newStatus == cellStatus::Killed){
        kill_enemys_ship(x, y);
        qDebug() << "cpp: <GameBoard> Корабль врага убит в " << x << " " << y;
    } else {
        cell = newStatus;
    }

    notifyBoardChanged();

    qDebug() << "cpp: <GameBoard> registerEnemyAnswer called:"
             << x << y << result;

    qDebug() << "enemy cell now ="
             << static_cast<int>(cell);
}

void GameBoard::kill_enemys_ship(int x, int y)
{
    // Проверка начальных координат
    if (x < 0 || y < 0 ||
        x >= BoardSize || y >= BoardSize) {
        return;
    }

    // Центральная клетка уничтоженного корабля
    e_cells[y][x] = cellStatus::Killed;

    // Ищем повреждённые клетки влево
    int rx = x - 1;

    while (rx >= 0 &&
           e_cells[y][rx] == cellStatus::Damaged) {

        e_cells[y][rx] = cellStatus::Killed;
        --rx;
    }

    // Ищем повреждённые клетки вправо
    rx = x + 1;

    while (rx < BoardSize &&
           e_cells[y][rx] == cellStatus::Damaged) {

        e_cells[y][rx] = cellStatus::Killed;
        ++rx;
    }

    // Ищем повреждённые клетки вверх
    int ry = y - 1;

    while (ry >= 0 &&
           e_cells[ry][x] == cellStatus::Damaged) {

        e_cells[ry][x] = cellStatus::Killed;
        --ry;
    }

    // Ищем повреждённые клетки вниз
    ry = y + 1;

    while (ry < BoardSize &&
           e_cells[ry][x] == cellStatus::Damaged) {

        e_cells[ry][x] = cellStatus::Killed;
        ++ry;
    }

    // Границы конкретного корабля
    int startX = x;
    int endX = x;
    int startY = y;
    int endY = y;

    // Проверяем, есть ли часть корабля слева или справа
    const bool horizontal =
        (x > 0 &&
         e_cells[y][x - 1] == cellStatus::Killed) ||
        (x < BoardSize - 1 &&
         e_cells[y][x + 1] == cellStatus::Killed);

    if (horizontal) {
        // Находим левую границу корабля
        while (startX > 0 &&
               e_cells[y][startX - 1] == cellStatus::Killed) {
            --startX;
        }

        // Находим правую границу корабля
        while (endX < BoardSize - 1 &&
               e_cells[y][endX + 1] == cellStatus::Killed) {
            ++endX;
        }

        // Обводим горизонтальный корабль
        for (int row = y - 1; row <= y + 1; ++row) {
            for (int col = startX - 1; col <= endX + 1; ++col) {
                if (row < 0 || col < 0 ||
                    row >= BoardSize || col >= BoardSize) {
                    continue;
                }

                // Shot означает промах
                // Не затираем Killed, Damaged и уже существующий Shot
                if (e_cells[row][col] == cellStatus::Clean) {
                    e_cells[row][col] = cellStatus::Shot;
                }
            }
        }
    } else {
        // Вертикальный корабль или корабль длиной 1

        // Находим верхнюю границу корабля
        while (startY > 0 &&
               e_cells[startY - 1][x] == cellStatus::Killed) {
            --startY;
        }

        // Находим нижнюю границу корабля
        while (endY < BoardSize - 1 &&
               e_cells[endY + 1][x] == cellStatus::Killed) {
            ++endY;
        }

        // Обводим вертикальный корабль
        for (int row = startY - 1; row <= endY + 1; ++row) {
            for (int col = x - 1; col <= x + 1; ++col) {
                if (row < 0 || col < 0 ||
                    row >= BoardSize || col >= BoardSize) {
                    continue;
                }

                if (e_cells[row][col] == cellStatus::Clean) {
                    e_cells[row][col] = cellStatus::Shot;
                }
            }
        }
    }
}

void GameBoard::kill_my_ship(int x, int y)
{
    // Проверка начальных координат
    if (x < 0 || y < 0 ||
        x >= BoardSize || y >= BoardSize) {
        return;
    }

    // Центральная клетка уничтоженного корабля
    m_cells[y][x] = cellStatus::Killed;

    // Ищем повреждённые клетки влево
    int rx = x - 1;

    while (rx >= 0 &&
           m_cells[y][rx] == cellStatus::Damaged) {

        m_cells[y][rx] = cellStatus::Killed;
        --rx;
    }

    // Ищем повреждённые клетки вправо
    rx = x + 1;

    while (rx < BoardSize &&
           m_cells[y][rx] == cellStatus::Damaged) {

        m_cells[y][rx] = cellStatus::Killed;
        ++rx;
    }

    // Ищем повреждённые клетки вверх
    int ry = y - 1;

    while (ry >= 0 &&
           m_cells[ry][x] == cellStatus::Damaged) {

        m_cells[ry][x] = cellStatus::Killed;
        --ry;
    }

    // Ищем повреждённые клетки вниз
    ry = y + 1;

    while (ry < BoardSize &&
           m_cells[ry][x] == cellStatus::Damaged) {

        m_cells[ry][x] = cellStatus::Killed;
        ++ry;
    }

    // Границы конкретного корабля
    int startX = x;
    int endX = x;
    int startY = y;
    int endY = y;

    // Проверяем, есть ли часть корабля слева или справа
    const bool horizontal =
        (x > 0 &&
         m_cells[y][x - 1] == cellStatus::Killed) ||
        (x < BoardSize - 1 &&
         m_cells[y][x + 1] == cellStatus::Killed);

    if (horizontal) {
        // Находим левую границу корабля
        while (startX > 0 &&
               m_cells[y][startX - 1] == cellStatus::Killed) {
            --startX;
        }

        // Находим правую границу корабля
        while (endX < BoardSize - 1 &&
               m_cells[y][endX + 1] == cellStatus::Killed) {
            ++endX;
        }

        // Обводим горизонтальный корабль
        for (int row = y - 1; row <= y + 1; ++row) {
            for (int col = startX - 1; col <= endX + 1; ++col) {
                if (row < 0 || col < 0 ||
                    row >= BoardSize || col >= BoardSize) {
                    continue;
                }

                // Shot означает промах
                // Не затираем Killed, Damaged и Shot
                if (m_cells[row][col] == cellStatus::Clean) {
                    m_cells[row][col] = cellStatus::Shot;
                }
            }
        }
    } else {
        // Вертикальный корабль или корабль длиной 1

        // Находим верхнюю границу корабля
        while (startY > 0 &&
               m_cells[startY - 1][x] == cellStatus::Killed) {
            --startY;
        }

        // Находим нижнюю границу корабля
        while (endY < BoardSize - 1 &&
               m_cells[endY + 1][x] == cellStatus::Killed) {
            ++endY;
        }

        // Обводим вертикальный корабль
        for (int row = startY - 1; row <= endY + 1; ++row) {
            for (int col = x - 1; col <= x + 1; ++col) {
                if (row < 0 || col < 0 ||
                    row >= BoardSize || col >= BoardSize) {
                    continue;
                }

                // Shot означает промах
                if (m_cells[row][col] == cellStatus::Clean) {
                    m_cells[row][col] = cellStatus::Shot;
                }
            }
        }
    }
}