#ifndef GAMEBOARD_H
#define GAMEBOARD_H

#include <QObject>
#include <cstdint>

class GameBoard : public QObject
{
    Q_OBJECT
    friend class ai_player;

public:
    enum class cellStatus: uint8_t{
        Clean = 0,
        Ship = 1,
        Shot = 2,
        Damaged = 3,
        Killed = 4
    };
    Q_ENUM(cellStatus);

    enum class answerStatus: uint8_t{
        Miss = 0,
        Hit = 1,
        Kill = 2
    };
    Q_ENUM(answerStatus);

    explicit GameBoard(QObject *parent = nullptr);

    static const int BoardSize = 10;

    // Проверка, можно ли поставить корабль
    Q_INVOKABLE bool canPlaceShip(int x, int y, int length, bool horizontal);
    // Отметить корабль на поле
    Q_INVOKABLE void placeShip(int x, int y, int length, bool horizontal);
    // Снять корабль с поля
    Q_INVOKABLE void removeShip(int x, int y, int length, bool horizontal);
    // Полностью очистить оба поля
    Q_INVOKABLE void clearBoards();
    // Проверка есть ли что-нибудь в клетке
    Q_INVOKABLE bool cellOccupied(int x, int y) const;

    // статус клетки для m_cells
    Q_INVOKABLE int myCellStatusAt(int x, int y) const;
    // статус клетки для e_cells
    Q_INVOKABLE int enemyCellStatusAt(int x, int y) const;

    // Действия:
    // регистрация ответа противника
    Q_INVOKABLE void registerEnemyAnswer(int x, int y, int result);
    // обновление обоих полей
    Q_PROPERTY(int boardRevision READ boardRevision NOTIFY boardChanged)
    // обозначение корабля при убийстве на поле врага
    void kill_enemys_ship(int x, int y);
    // обозначение корабля при убийстве на своем поле
    void kill_my_ship(int x, int y);

    int boardRevision() const
    {
        return m_boardRevision;
    }
signals:
    void boardChanged();

private:
    void notifyBoardChanged();
    cellStatus m_cells[BoardSize][BoardSize];
    cellStatus e_cells[BoardSize][BoardSize];

    int m_boardRevision = 0;
};

#endif // GAMEBOARD_H