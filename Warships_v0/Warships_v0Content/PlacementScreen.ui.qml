import QtQuick
import QtQuick.Controls

Rectangle {
    id: root
    anchors.fill: parent
    color: "#f0f4f8"

    property int cellSize: 40
    property int boardSize: 10
    property int boardX: 40
    property int boardY: 120

    Text {
        text: "РАССТАНОВКА КОРАБЛЕЙ"
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.topMargin: 30
        font.pixelSize: 28
        font.bold: true
    }

    Rectangle {
        id: board
        x: root.boardX
        y: root.boardY
        width: root.boardSize * root.cellSize
        height: root.boardSize * root.cellSize
        color: "white"
        border.color: "#263238"
        border.width: 2

        Repeater {
            model: 100
            Rectangle {
                width: root.cellSize - 1
                height: root.cellSize - 1
                x: (index % 10) * root.cellSize
                y: Math.floor(index / 10) * root.cellSize
                color: "transparent"
                border.color: "#b0bec5"
                border.width: 1
            }
        }
    }

    ShipItem {
        id: ship1
        x: root.boardX + 500
        y: root.boardY
        cellSize: root.cellSize
        boardX: root.boardX
        boardY: root.boardY
        shipLength: 4
    }

    ShipItem {
        id: ship2
        x: root.boardX + 500
        y: root.boardY + 70
        cellSize: root.cellSize
        boardX: root.boardX
        boardY: root.boardY
        shipLength: 3
    }

    ShipItem {
        id: ship3
        x: root.boardX + 500
        y: root.boardY + 140
        cellSize: root.cellSize
        boardX: root.boardX
        boardY: root.boardY
        shipLength: 2
    }

    Button {
        text: "Готово"
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 30
    }
}
