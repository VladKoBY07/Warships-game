#ifndef AI_PLAYER_H
#define AI_PLAYER_H

#include <QObject>
#include "gameboard.h"

class ai_player : public QObject
{
    Q_OBJECT
public:
    explicit ai_player(QObject *parent = nullptr);

    bool canPlaceShip(int x, int y, int length, bool horizontal);

    bool isZoneClear(int startX, int startY, int length, bool horizontal);

    void clearBoard();

    void placeShip(int x, int y, int length, bool horizontal);

    Q_INVOKABLE void generateRandomPlacement();

private:
    static const int BoardSize = GameBoard::BoardSize;

    unsigned char ai_cells[BoardSize][BoardSize];

signals:
};

#endif // AI_PLAYER_H
