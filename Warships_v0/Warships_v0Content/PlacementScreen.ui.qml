import QtQuick
import QtQuick.Controls

Item {
    id: root
    width: 800
    height: 600

    // Игровое поле
    Rectangle {
        id: board
        anchors.left: parent.left
        anchors.leftMargin: 80
        anchors.verticalCenter: parent.verticalCenter
        width: 10 * 40
        height: 10 * 40
        color: "#FFFFFF"
        border.color: "#BDBDBD"
        border.width: 1

        property int cols: 10
        property int rows: 10
        property int cellSize: 40

        // сетка для визуализации
        Repeater {
            model: board.rows
            Rectangle {
                width: board.width
                height: board.cellSize
                y: index * board.cellSize
                color: "transparent"
                border.color: "#EEEEEE"
                border.width: 1
            }
        }

        Repeater {
            model: board.cols
            Rectangle {
                width: board.cellSize
                height: board.height
                x: index * board.cellSize
                color: "transparent"
                border.color: "#EEEEEE"
                border.width: 1
            }
        }
    }

    // Док для кораблей
    Rectangle {
        id: dock
        anchors.left: board.right
        anchors.leftMargin: 40
        anchors.top: board.top
        width: 200
        height: board.height
        color: "#EEEEEE"
        border.color: "#BDBDBD"
        border.width: 1
        radius: 8

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 8
            text: "Док"
            font.bold: true
            color: "#616161"
        }
    }

    // Корабли в доке
    ShipItem {
        id: ship4
        shipLength: 4
        cellSize: board.cellSize
        boardX: board.x
        boardY: board.y
        boardCols: board.cols
        boardRows: board.rows

        dockX: dock.x
        dockY: dock.y
        dockWidth: dock.width
        dockHeight: dock.height

        x: dock.x + 10
        y: dock.y + 30
    }

    ShipItem {
        id: ship3a
        shipLength: 3
        cellSize: board.cellSize
        boardX: board.x
        boardY: board.y
        boardCols: board.cols
        boardRows: board.rows

        dockX: dock.x
        dockY: dock.y
        dockWidth: dock.width
        dockHeight: dock.height

        x: dock.x + 10
        y: dock.y + 90
    }

    ShipItem {
        id: ship3b
        shipLength: 3
        cellSize: board.cellSize
        boardX: board.x
        boardY: board.y
        boardCols: board.cols
        boardRows: board.rows

        dockX: dock.x
        dockY: dock.y
        dockWidth: dock.width
        dockHeight: dock.height

        x: dock.x + 10
        y: dock.y + 150
    }

    ShipItem {
        id: ship2a
        shipLength: 2
        cellSize: board.cellSize
        boardX: board.x
        boardY: board.y
        boardCols: board.cols
        boardRows: board.rows

        dockX: dock.x
        dockY: dock.y
        dockWidth: dock.width
        dockHeight: dock.height

        x: dock.x + 10
        y: dock.y + 210
    }

    ShipItem {
        id: ship2b
        shipLength: 2
        cellSize: board.cellSize
        boardX: board.x
        boardY: board.y
        boardCols: board.cols
        boardRows: board.rows

        dockX: dock.x
        dockY: dock.y
        dockWidth: dock.width
        dockHeight: dock.height

        x: dock.x + 10
        y: dock.y + 270
    }

    // Кнопка "Готово" (по желанию)
    Button {
        id: readyButton
        text: "Готово"
        anchors.top: board.bottom
        anchors.topMargin: 20
        anchors.horizontalCenter: board.horizontalCenter
    }
}