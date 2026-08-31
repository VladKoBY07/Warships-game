import QtQuick
import QtQuick.Controls

Item {
    id: root

    property int shipLength: 3
    property bool horizontal: true

    // Поле
    property int cellSize: 40
    property int boardCols: 10
    property int boardRows: 10
    property int boardX: 0
    property int boardY: 0

    // Док
    property real dockX: 0
    property real dockY: 0
    property real dockWidth: 0
    property real dockHeight: 0

    // Состояние
    property bool placed: false        // установлен на поле
    property int gridX: -1            // левая клетка на поле
    property int gridY: -1

    width: horizontal ? shipLength * cellSize : cellSize
    height: horizontal ? cellSize : shipLength * cellSize

    Image {
        id: shipImage
        anchors.centerIn: parent
        source: "images/ships/ship" + shipLength + ".png"

        width: shipLength * cellSize
        height: cellSize

        rotation: root.horizontal ? 0 : 90
    }

    /*Rectangle {
        anchors.fill: parent
        radius: 6
        color: placed ? "#4CAF50" : "#2196F3"
        border.color: "#0D47A1"
        border.width: 2
    }*/

    function isInDock() {
        var centerX = root.x + root.width / 2
        var centerY = root.y + root.height / 2

        return centerX >= dockX &&
               centerX <= dockX + dockWidth &&
               centerY >= dockY &&
               centerY <= dockY + dockHeight
    }

    // Поиск ближайшей свободной позиции на поле вокруг заданной левой клетки
    function findNearestFreePosition(gx, gy, horiz) {
        var maxX = boardCols - (horiz ? shipLength : 1)
        var maxY = boardRows - (horiz ? 1 : shipLength)

        if (gx < 0) gx = 0
        if (gy < 0) gy = 0
        if (gx > maxX) gx = maxX
        if (gy > maxY) gy = maxY

        if (gameBoard.canPlaceShip(gx, gy, shipLength, horiz))
            return { x: gx, y: gy }

        for (var r = 1; r < boardCols + boardRows; ++r) {
            for (var dx = -r; dx <= r; ++dx) {
                for (var dy = -r; dy <= r; ++dy) {
                    var nx = gx + dx
                    var ny = gy + dy

                    if (nx < 0 || ny < 0 || nx > maxX || ny > maxY)
                        continue

                    if (gameBoard.canPlaceShip(nx, ny, shipLength, horiz)) {
                        return { x: nx, y: ny }
                    }
                }
            }
        }

        // если свободного места вообще нет – возвращаем исходные клетки
        return { x: gx, y: gy }
    }

    MouseArea {
        anchors.fill: parent
        drag.target: root
        drag.axis: Drag.XAndYAxis

        // Поворот
        onClicked: {
            if (root.isInDock()) {
                // В доке – поворот без пересечений
                root.horizontal = !root.horizontal
                root.width  = root.horizontal ? root.shipLength * root.cellSize : root.cellSize
                root.height = root.horizontal ? root.cellSize : root.shipLength * root.cellSize

                // Ограничиваем по доку
                if (root.x < root.dockX)
                    root.x = root.dockX
                if (root.y < root.dockY)
                    root.y = root.dockY
                if (root.x + root.width > root.dockX + root.dockWidth)
                    root.x = root.dockX + root.dockWidth - root.width
                if (root.y + root.height > root.dockY + root.dockHeight)
                    root.y = root.dockY + root.dockHeight - root.height

                return
            }

            // На поле – поворот вокруг левой клетки с автоподбором
            if (root.placed && root.gridX >= 0 && root.gridY >= 0) {
                var newHorizontal = !root.horizontal

                // снимаем корабль со старого положения
                gameBoard.removeShip(root.gridX, root.gridY, root.shipLength, root.horizontal)

                // ищем ближайшее свободное место для новой ориентации
                var pos = root.findNearestFreePosition(root.gridX, root.gridY, newHorizontal)

                if (!gameBoard.canPlaceShip(pos.x, pos.y, root.shipLength, newHorizontal)) {
                    // вообще нет места – возвращаем старое положение
                    gameBoard.placeShip(root.gridX, root.gridY, root.shipLength, root.horizontal)
                    return
                }

                root.horizontal = newHorizontal
                root.width  = root.horizontal ? root.shipLength * root.cellSize : root.cellSize
                root.height = root.horizontal ? root.cellSize : root.shipLength * root.cellSize

                gameBoard.placeShip(pos.x, pos.y, root.shipLength, root.horizontal)
                root.gridX = pos.x
                root.gridY = pos.y
                root.x = root.boardX + pos.x * root.cellSize
                root.y = root.boardY + pos.y * root.cellSize
                root.placed = true
            } else {
                // не в доке и не на поле – чисто визуальный поворот
                root.horizontal = !root.horizontal
                root.width  = root.horizontal ? root.shipLength * root.cellSize : root.cellSize
                root.height = root.horizontal ? root.cellSize : root.shipLength * root.cellSize
            }
        }

        onReleased: {
            var inDock = root.isInDock()

            if (inDock) {
                // корабль в доке – поле не трогаем
                if (root.placed && root.gridX >= 0 && root.gridY >= 0) {
                    gameBoard.removeShip(root.gridX, root.gridY, root.shipLength, root.horizontal)
                }
                root.placed = false
                root.gridX = -1
                root.gridY = -1
                return
            }

            // На поле: освободить старое место (если было)
            if (root.placed && root.gridX >= 0 && root.gridY >= 0) {
                gameBoard.removeShip(root.gridX, root.gridY, root.shipLength, root.horizontal)
            }

            // целевая левая клетка по текущему положению
            var gx = Math.round((root.x - root.boardX) / root.cellSize)
            var gy = Math.round((root.y - root.boardY) / root.cellSize)

            // найти ближайшее свободное место с текущей ориентацией
            var pos = root.findNearestFreePosition(gx, gy, root.horizontal)

            if (!gameBoard.canPlaceShip(pos.x, pos.y, shipLength, horizontal)) {
                // вообще нет свободного места – корабль считается не установленным
                root.placed = false
                root.gridX = -1
                root.gridY = -1
                return
            }

            // ставим корабль в найденное место
            gameBoard.placeShip(pos.x, pos.y, shipLength, horizontal)

            root.gridX = pos.x
            root.gridY = pos.y
            root.x = boardX + pos.x * cellSize
            root.y = boardY + pos.y * cellSize
            root.placed = true
        }
    }

    Behavior on x { NumberAnimation { duration: 120 } }
    Behavior on y { NumberAnimation { duration: 120 } }
}
