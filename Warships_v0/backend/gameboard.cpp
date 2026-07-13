#include "gameboard.h"
#include <QDebug>

GameBoard::GameBoard(QObject *parent)
    : QObject{parent}
{
    clearBoards();
}

void GameBoard::clearBoards()
{
    for (int row = 0; row < BoardSize; ++row) {
        for (int col = 0; col < BoardSize; ++col) {
            m_cells[row][col] = cellStatus::Clean;
        }
    }

    for (int row = 0; row < BoardSize; ++row) {
        for (int col = 0; col < BoardSize; ++col) {
            e_cells[row][col] = cellStatus::Clean;
        }
    }
}

bool GameBoard::canPlaceShip(int x, int y, int length, bool horizontal)
{
    // Проверки границ
    if (x < 0 || y < 0 || x >= BoardSize || y >= BoardSize)
        return false;

    if (horizontal) {
        if (x + length > BoardSize)
            return false;
        // Проверка клеток корабля
        for (int i = 0; i < length; ++i) {
            if (m_cells[y][x + i] != cellStatus::Clean)
                return false;
        }
        // Проверка зоны вокруг корабля
        int startX = std::max(0, x - 1);
        int endX   = std::min(BoardSize - 1, x + length);
        int startY = std::max(0, y - 1);
        int endY   = std::min(BoardSize - 1, y + 1);

        for (int yy = startY; yy <= endY; ++yy) {
            for (int xx = startX; xx <= endX; ++xx) {
                if (m_cells[yy][xx] != cellStatus::Clean)
                    return false;
            }
        }
    } else {
        if (y + length > BoardSize)
            return false;
        // Проверка клеток корабля
        for (int i = 0; i < length; ++i) {
            if (m_cells[y + i][x] != cellStatus::Clean)
                return false;
        }
        // Проверка зоны вокруг корабля
        int startX = std::max(0, x - 1);
        int endX   = std::min(BoardSize - 1, x + 1);
        int startY = std::max(0, y - 1);
        int endY   = std::min(BoardSize - 1, y + length);

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
}

void GameBoard::removeShip(int x, int y, int length, bool horizontal)
{
    if (horizontal) {
        for (int i = 0; i < length; ++i) {
            int cx = x + i;
            if (cx >= 0 && cx < BoardSize && y >= 0 && y < BoardSize)
                m_cells[y][cx] = cellStatus::Clean;
        }
    } else {
        for (int i = 0; i < length; ++i) {
            int cy = y + i;
            if (x >= 0 && x < BoardSize && cy >= 0 && cy < BoardSize)
                m_cells[cy][x] = cellStatus::Clean;
        }
    }
}

bool GameBoard::cellOccupied(int x, int y) const {
    if (x < 0 || y < 0 || x >= BoardSize || y >= BoardSize)
        return false;
    return m_cells[y][x] != cellStatus::Clean;
}

// статус клеток
int GameBoard::myCellStatusAt(int x, int y) const
{
    if (x < 0 || y < 0 || x >= BoardSize || y >= BoardSize)
        return static_cast<int>(cellStatus::Clean);
    return static_cast<int>(m_cells[y][x]);
}
int GameBoard::enemyCellStatusAt(int x, int y) const
{
    if (x < 0 || y < 0 || x >= BoardSize || y >= BoardSize)
        return static_cast<int>(cellStatus::Clean);
    return static_cast<int>(e_cells[y][x]);
}

// атака
void GameBoard::registerEnemyAnswer(int x, int y, int result)
{
    if (x < 0 || y < 0 || x >= BoardSize || y >= BoardSize)
        return;

    cellStatus &cell = e_cells[y][x];

    switch (result) {
    case static_cast<int>(answerStatus::Miss):
        cell = cellStatus::Shot;
        break;
    case static_cast<int>(answerStatus::Hit):
        cell = cellStatus::Damaged;
        break;
    case static_cast<int>(answerStatus::Kill):
        cell = cellStatus::Killed;
    default:
        break;
    }

    ++m_enemyBoardRevision;
    emit enemyBoardChanged();

    qDebug() << "registerEnemyAnswer called" << x << y << result;
    qDebug() << "enemy cell now =" << static_cast<int>(cell);
}