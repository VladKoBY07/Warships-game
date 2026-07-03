import QtQuick
import QtQuick.Controls

Item {
    id: root

    property int shipLength: 3
    property bool horizontal: true
    property int cellSize: 40
    property int boardCols: 10
    property int boardRows: 10
    property int boardX: 0
    property int boardY: 0
    property bool placed: false

    property int gridX: 0
    property int gridY: 0

    width: horizontal ? shipLength * cellSize : cellSize
    height: horizontal ? cellSize : shipLength * cellSize

    Rectangle {
        anchors.fill: parent
        radius: 6
        color: placed ? "#4CAF50" : "#2196F3"
        border.color: "#0D47A1"
        border.width: 2
    }

    MouseArea {
        anchors.fill: parent
        drag.target: root
        drag.axis: Drag.XAndYAxis

        onClicked: {
            root.horizontal = !root.horizontal
            root.width = root.horizontal ? root.shipLength * root.cellSize : root.cellSize
            root.height = root.horizontal ? root.cellSize : root.shipLength * root.cellSize
        }

        onReleased: {
            var gx = Math.round((root.x - root.boardX) / root.cellSize)
            var gy = Math.round((root.y - root.boardY) / root.cellSize)

            if (gx < 0) gx = 0
            if (gy < 0) gy = 0

            var maxX = root.boardCols - (root.horizontal ? root.shipLength : 1)
            var maxY = root.boardRows - (root.horizontal ? 1 : root.shipLength)

            if (gx > maxX) gx = maxX
            if (gy > maxY) gy = maxY

            root.gridX = gx
            root.gridY = gy
            root.x = root.boardX + gx * root.cellSize
            root.y = root.boardY + gy * root.cellSize
            root.placed = true
        }
    }

    Behavior on x { NumberAnimation { duration: 120 } }
    Behavior on y { NumberAnimation { duration: 120 } }
}
