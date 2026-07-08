#ifndef AI_PLAYER_H
#define AI_PLAYER_H

#include <QObject>
#include "gameboard.h"

class ai_player : public QObject
{
    Q_OBJECT
public:
    explicit ai_player(QObject *parent = nullptr);

    GameBoard aiBoard;

    Q_INVOKABLE void generateRandomPlacement();

    Q_INVOKABLE int receiveAttack(int x, int y);

    void calculateShoot(int& x, int& y);

    Q_INVOKABLE void performAttack();



};

#endif // AI_PLAYER_H
