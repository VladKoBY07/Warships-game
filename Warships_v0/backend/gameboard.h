#ifndef GAMEBOARD_H
#define GAMEBOARD_H

#include <QObject>

class GameBoard : public QObject
{
    Q_OBJECT
public:
    explicit GameBoard(QObject *parent = nullptr);

    // Проверка, можно ли поставить корабль
    Q_INVOKABLE bool canPlaceShip(int x, int y, int length, bool horizontal);
    // Отметить корабль на поле
    Q_INVOKABLE void placeShip(int x, int y, int length, bool horizontal);
    // Снять корабль с поля
    Q_INVOKABLE void removeShip(int x, int y, int length, bool horizontal);
    // Полностью очистить поле
    Q_INVOKABLE void clearBoard();

private:
    static const int BoardSize = 10;
    bool m_cells[BoardSize][BoardSize];
};

#endif // GAMEBOARD_H