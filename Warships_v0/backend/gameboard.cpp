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

    cell = newStatus;

    notifyBoardChanged();

    qDebug() << "cpp: <GameBoard> registerEnemyAnswer called:"
             << x << y << result;

    qDebug() << "enemy cell now ="
             << static_cast<int>(cell);
}