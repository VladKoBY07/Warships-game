import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import Warships 1.0
import QtMultimedia

Item {
    id: placementScreen
    anchors.fill: parent

    property StackView stackView: StackView.view

    property string overlayText: "Подготовка к бою"

    property bool playerReady: false
    property bool opponentReady: false

    // Абсолютные координаты статичного дока (в системе координат gameContent)
    readonly property real dockAbsX: dock.x
    readonly property real dockAbsY: dock.y

    readonly property int currentGamemode:
        gameController.gamemode

    // Сброс состояния при входе на экран
    onVisibleChanged: {
        if (placementScreen.visible) {
            console.log(
                "PlacementScreen: visible, gamemode =",
                placementScreen.currentGamemode
            )

            placementScreen.playerReady = false
            placementScreen.opponentReady = false

            gameContent.enabled = false
            blurEffect.amount = 0.0
            dimOverlay.opacity = 0.0

            introText.text = "Подготовка к бою"
            introText.color = "#C1C9CC"
        }
    }

    // Раскладка кораблей в доке: длина + смещение (ox, oy) внутри дока.
    ListModel {
        id: shipDockLayout

        // 4-палубный
        ListElement { len: 4; ox: 15;  oy: 50  }

        // два 3-палубных
        ListElement { len: 3; ox: 15;  oy: 110 }
        ListElement { len: 3; ox: 15;  oy: 170 }

        // три 2-палубных
        ListElement { len: 2; ox: 15;  oy: 230 }
        ListElement { len: 2; ox: 15; oy: 290 }
        ListElement { len: 2; ox: 15;  oy: 350 }

        // четыре 1-палубных
        ListElement { len: 1; ox: 15;  oy: 410 }
        ListElement { len: 1; ox: 75;  oy: 410 }
        ListElement { len: 1; ox: 135; oy: 410 }
        ListElement { len: 1; ox: 195; oy: 410 }
    }

    Video{
        id: placementBG
        anchors.fill: parent
        source: "images/SeaAnimated.mp4"
        playbackRate: 1
        fillMode: VideoOutput.PreserveAspectCrop
        loops: MediaPlayer.Infinite

        Image {
            anchors.fill: parent
            source: "images/Sea.jpg"
            fillMode: Image.PreserveAspectCrop
            visible: placementBG.playbackState !== MediaPlayer.PlayingState
        }

        Component.onCompleted: play()
    }

    // ===== Весь игровой контент — можно блюрить и блокировать целиком =====
    Item {
        id: gameContent
        anchors.fill: parent
        enabled: false
        z: 5

        // белые плашки вокруг поля
        Rectangle {
            id: topOverlay
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: board.top
            z: 1
            color: "#162433"
            opacity: 0.8
        }

        Rectangle {
            id: bottomOverlay
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: board.bottom
            anchors.bottom: parent.bottom
            z: 1
            color: "#162433"
            opacity: 0.8
        }

        Rectangle {
            id: leftOverlay
            anchors.left: parent.left
            anchors.right: board.left
            anchors.top: board.top
            anchors.bottom: board.bottom
            z: 1
            color: "#162433"
            opacity: 0.8
        }

        Rectangle {
            id: rightOverlay
            anchors.left: board.right
            anchors.right: parent.right
            anchors.top: board.top
            anchors.bottom: board.bottom
            z: 1
            color: "#162433"
            opacity: 0.8
        }

        Rectangle {
            id: board
            anchors.centerIn: parent
            width: 10 * 50
            height: 10 * 50
            color: "#162433"
            opacity: 0.3
            border.color: "#C1C9CC"
            border.width: 3
            z: 2

            property int cols: 10
            property int rows: 10
            property int cellSize: 50

            Repeater {
                model: board.rows
                Rectangle {
                    width: board.width
                    height: board.cellSize
                    y: index * board.cellSize
                    color: "transparent"
                    border.color: "#C1C9CC"
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
                    border.color: "#C1C9CC"
                    border.width: 1
                }
            }
        }

        Rectangle {
            id: dock
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.top: board.top
            width: 260
            height: board.height
            color: "transparent"
            z: 3

            Image {
                id: dockBG
                anchors.fill: parent
                source: "images/DockTable.png"
                fillMode: Image.Stretch
                z: 0
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 12
                text: "Док"
                font.bold: true
                color: "#616161"
                z: 1
            }
        }

        // ===== Корабли — дети gameContent, свободно перетаскиваются по всему экрану =====
        Repeater {
            id: shipRepeater
            model: shipDockLayout

            ShipItem {
                id: shipDelegate
                z: 5

                shipLength: len
                cellSize: board.cellSize
                boardX: board.x
                boardY: board.y
                boardCols: board.cols
                boardRows: board.rows

                dockX: placementScreen.dockAbsX
                dockY: placementScreen.dockAbsY
                dockWidth: dock.width
                dockHeight: dock.height

                x: placementScreen.dockAbsX + ox
                y: placementScreen.dockAbsY + oy

                property bool suppressMoveAnim: false

                // Блокировка только в Local и только если игрок готов
                enabled: placementScreen.currentGamemode
                         !== GameController.Local
                         || !placementScreen.playerReady

                Behavior on x {
                    enabled: !suppressMoveAnim
                    NumberAnimation {
                        duration: 120
                    }
                }

                Behavior on y {
                    enabled: !suppressMoveAnim
                    NumberAnimation {
                        duration: 120
                    }
                }
            }
        }

        Button {
            id: readyButton
            z: 10

            width: board.width * 0.5
            height: width / 3.4

            font.letterSpacing: 0.3
            font.styleName: "Bold"
            font.weight: Font.ExtraBold
            palette.buttonText: "#C1C9CC"
            font.family: "Verdana"
            font.pointSize: height / 4
            font.bold: true

            text: placementScreen.playerReady
                  ? "Отмена"
                  : "Готово"

            anchors.top: board.bottom
            anchors.topMargin: 50
            anchors.horizontalCenter: board.horizontalCenter

            // В PvAI кнопка всегда включена
            // В Local:
            //   - «Готово» доступно, пока игрок не готов
            //   - «Отмена» доступна, пока соперник не начал игру
            enabled: placementScreen.currentGamemode !== GameController.Local
                         || (placementScreen.playerReady
                             ? !placementScreen.opponentReady
                             : true)

            leftPadding: readyButton.pressed ? 8 : 2
            topPadding: readyButton.pressed ? 8 : 2

            background: Image {
                source: readyButton.pressed? "images/ButtonBG_pressed.png" :
                        readyButton.hovered? "images/ButtonBG_hover.png" :
                                            "images/ButtonBG_not_pressed.png"
                fillMode: Image.Stretch
            }
        }

        Connections {
            target: readyButton

            function onClicked() {
                console.log(
                    "<PlacementScreen> readyButton: gamemode =",
                    placementScreen.currentGamemode,
                    "PvAI =",
                    GameController.PvAI
                )

                var allPlaced = true

                for (var i = 0; i < shipRepeater.count; ++i) {
                    if (!shipRepeater.itemAt(i).placed) {
                        allPlaced = false
                        break
                    }
                }

                if (!allPlaced) {
                    warningBlinkAnimation.start()
                    return
                }

                // PvAI: сразу переходим на GameScreen
                if (placementScreen.currentGamemode
                    === GameController.PvAI) {

                    console.log("<PlacementScreen> PvAI: переход на GameScreen")

                    placementScreen.stackView.push(
                        Qt.resolvedUrl("GameScreen.qml")
                    )

                    return
                }

                // Local: проверка готовности противника
                if (placementScreen.playerReady) {

                    placementScreen.playerReady = false
                    gameController.setPlayerReady(false)

                    // Отмена готовности
                    shipRepeater.enabled = true
                    clearButton.enabled = true

                    introText.text = "Подготовка к бою"
                    introText.color = "#C1C9CC"
                    introText.opacity = 1.0

                    return
                }

                // Игрок нажимает «Готово»
                placementScreen.playerReady = true
                gameController.setPlayerReady(true)

                // Блокируем перемещение кораблей
                shipRepeater.enabled = false
                clearButton.enabled = false

                // Проверяем, готов ли соперник. Если оба готовы - начинаем игру
                if (placementScreen.opponentReady) {

                    placementScreen.stackView.push(
                        Qt.resolvedUrl("GameScreen.qml")
                    )
                } else {
                    introText.text = "Ожидаем соперника..."
                    introText.color = "#F57C00"
                    introText.opacity = 1.0
                }
            }
        }

        Button {
            id: clearButton
            anchors.top: board.top
            anchors.left: board.right
            width: 100
            height: 100
            z: 10

            Rectangle{
                anchors.fill: parent
                color: "#162433"
                border.color: "#C1C9CC"
                border.width: 2
                z: 0
            }

            Image {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                anchors.topMargin: 15
                anchors.bottomMargin: 15
                source: "images/DeleteIcon.png"
                z: 1
            }
        }

        Button {
            id: randomButton
            anchors.top: clearButton.bottom
            anchors.left: board.right
            width: 100
            height: 100
            z: 10

            Rectangle{
                anchors.fill: parent
                color: "#162433"
                border.color: "#C1C9CC"
                border.width: 2
                z: 0
            }

            Image {
                anchors.fill: parent
                anchors.leftMargin: 15
                anchors.rightMargin: 15
                anchors.topMargin: 15
                anchors.bottomMargin: 15
                source: "images/RandomIcon.png"
                z: 1
            }
        }
        Connections {
            target: randomButton
            function onClicked() {
                placementScreen.placeShipsRandomly()
            }
        }


        Rectangle {
            visible: placementScreen.currentGamemode
                    === GameController.Local

            id: networkStatusWindow
            anchors.right: parent.right
            anchors.rightMargin: 20
            anchors.top: board.top
            width: 260
            height: board.height
            color: "transparent"
            z: 3

            Image {
                anchors.fill: parent
                source: "images/DockTable.png"
                fillMode: Image.Stretch
                z: 0
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 12
                text: "Противник"
                font.bold: true
                color: "#616161"
                z: 1
            }

            Image {
                id: enemyAvatar
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 50
                source: "images/Avatar.png"
                width: 100
                height: 100
            }

            Text {
                id: enemyName
                anchors.horizontalCenter: enemyAvatar.horizontalCenter
                anchors.top: enemyAvatar.bottom
                anchors.topMargin: 10
                font.pixelSize: 18
                color: "#C1C9CC"
                text: {
                    if (gameController.gamemode === GameController.Local)
                        return networkManager.enemyName();

                    return ""
                }
            }

            Text {
                id: enemyStatus
                anchors.horizontalCenter: enemyName.horizontalCenter
                anchors.top: enemyName.bottom
                anchors.topMargin: 10
                text: {
                    if (placementScreen.currentGamemode
                        !== GameController.Local) {
                        return ""
                    }

                    return placementScreen.opponentReady
                           ? "Готов"
                           : "Не готов"
                }

                color: placementScreen.opponentReady
                       ? "#2E7D32"
                       : "#F57C00"

                font.bold: true
                font.pixelSize: 18
            }
        }



        Connections {
            target: clearButton
            function onClicked() {
                gameBoard.clearBoards()

                for (var i = 0; i < shipRepeater.count; ++i) {
                    var shipItem = shipRepeater.itemAt(i)
                    var homeSpot = shipDockLayout.get(i)

                    shipItem.suppressMoveAnim = true

                    shipItem.placed = false
                    shipItem.gridX = -1
                    shipItem.gridY = -1
                    shipItem.horizontal = true
                    shipItem.width = shipItem.shipLength * shipItem.cellSize
                    shipItem.height = shipItem.cellSize
                    shipItem.x = placementScreen.dockAbsX + homeSpot.ox
                    shipItem.y = placementScreen.dockAbsY + homeSpot.oy

                    shipItem.suppressMoveAnim = false
                }
            }
        }

    }

    // ===== Блюр поверх gameContent =====
    MultiEffect {
        id: blurEffect
        anchors.fill: gameContent
        source: gameContent
        blurEnabled: true
        blurMax: 32
        autoPaddingEnabled: true

        property real amount: 0.0
        blur: amount
        z: 20
    }

    // Затемнение фона
    Rectangle {
        id: dimOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: 0.0
        z: 15
    }

    // ===== Текстовая плашка — используется и при входе на экран
    Rectangle {
        id: introBox
        width: 500
        height: 200
        color: "transparent"
        opacity: 0.0
        anchors.horizontalCenter: parent.horizontalCenter
        y: placementScreen.height / 2 - height / 2 // стартовая позиция — по центру экрана
        z: 40

        Image {
            id: introBG
            anchors.fill: parent
            source: "images/Logo_BG.png"
            fillMode: Image.Stretch
            z: 0
        }

        Text {
            id: introText
            anchors.centerIn: parent
            topPadding: 75
            text: "Подготовка к бою"
            font.pixelSize: 30
            font.bold: true
            color: "#C1C9CC"
            z: 1
        }
    }

    SequentialAnimation {
        id: warningBlinkAnimation
        running: false
        ScriptAction {
            script: {
                introText.text = "Не все корабли расставлены!"
                introText.color = "#F44336"
                introText.opacity = 1.0
            }
        }


        NumberAnimation {
            target: introText
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 700
        }
        NumberAnimation {
            target: introText
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 500
        }
        NumberAnimation {
            target: introText
            property: "opacity"
            from: 1.0
            to: 0.0
            duration: 700
        }

        ScriptAction {
            script: {
                introText.text = "Подготовка к бою"
                introText.color = "#C1C9CC"
            }
        }

        NumberAnimation {
            target: introText
            property: "opacity"
            from: 0.0
            to: 1.0
            duration: 500
        }
    }

    // ===== Анимация появления экрана (при входе на страницу) =====
    SequentialAnimation {
        id: introAnimation
        running: true

        ParallelAnimation {
            NumberAnimation { target: blurEffect; property: "amount"; from: 0.0; to: 1.0; duration: 300; easing.type: Easing.OutQuad }
            NumberAnimation { target: dimOverlay; property: "opacity"; from: 0.0; to: 0.35; duration: 300 }
        }

        NumberAnimation { target: introBox; property: "opacity"; from: 0.0; to: 1.0; duration: 250 }

        PauseAnimation { duration: 700 }

        NumberAnimation {
            target: introBox
            property: "y"
            to: 10
            duration: 500
            easing.type: Easing.InOutQuad
        }

        ParallelAnimation {
            NumberAnimation { target: blurEffect; property: "amount"; from: 1.0; to: 0.0; duration: 300; easing.type: Easing.InQuad }
            NumberAnimation { target: dimOverlay; property: "opacity"; from: 0.35; to: 0.0; duration: 300 }
        }

        ScriptAction { script: gameContent.enabled = true }
        ScriptAction { script: introBox.anchors.top = placementScreen.top }
        ScriptAction { script: introBox.anchors.topMargin = 10 }
    }

    Connections {
        target: gameController

        function onOpponentReadyChanged() {
            placementScreen.opponentReady =
                gameController.opponentReady

            // Если оба готовы — переходим на GameScreen
            if (placementScreen.playerReady
            && placementScreen.opponentReady) {

                // Небольшая задержка перед переходом
                transitionTimer.start()
            }
        }
    }

    Timer {
        id: transitionTimer
        interval: 500
        running: false
        repeat: false

        onTriggered: {
            introText.text = "Подготовка к бою"
            introText.color = "#C1C9CC"
            introText.opacity = 1.0

            placementScreen.stackView.push(
                Qt.resolvedUrl("GameScreen.qml")
            )
        }
    }

    // ===== Функция случайной расстановки кораблей =====
    function placeShipsRandomly() {

        gameBoard.clearBoards()

        var ships = []
        for (var i = 0; i < shipDockLayout.count; ++i) {
            ships.push(shipDockLayout.get(i).len)
        }

        var maxAttempts = 30
        var success = false

        for (var attempt = 0; attempt < maxAttempts; ++attempt) {
            gameBoard.clearBoards()

            var attemptOk = true

            for (var s = 0; s < ships.length; ++s) {
                var len = ships[s]

                var placed = false
                var tryCount = 0
                var maxTries = 200

                while (!placed && tryCount < maxTries) {
                    ++tryCount

                    // Случайная ориентация
                    var horiz = Math.random() < 0.5

                    // Допустимые диапазоны для левой верхней клетки
                    var maxX = board.cols - (horiz ? len : 1)
                    var maxY = board.rows - (horiz ? 1 : len)

                    var gx = Math.floor(Math.random() * (maxX + 1))
                    var gy = Math.floor(Math.random() * (maxY + 1))

                    if (gameBoard.canPlaceShip(gx, gy, len, horiz)) {
                        gameBoard.placeShip(gx, gy, len, horiz)
                        placed = true
                    }
                }

                if (!placed) {
                    attemptOk = false
                    break
                }
            }

            if (attemptOk) {
                success = true
                break
            }
        }

        if (!success) {
            gameBoard.clearBoards()
        }
        syncShipsToBoard()
    }

    // ===== Синхронизация ShipItem с состоянием поля =====
    function syncShipsToBoard() {

        var foundShips = []

        var visited = []
        var xx, yy, k

        for (yy = 0; yy < board.rows; ++yy) {
            visited[yy] = []
            for (xx = 0; xx < board.cols; ++xx) {
                visited[yy][xx] = false
            }
        }

        for (var y = 0; y < board.rows; ++y) {
            for (var x = 0; x < board.cols; ++x) {
                var status = gameBoard.myCellStatusAt(x, y)
                if (status !== 1) // 1 == Ship
                    continue

                if (visited[y][x])
                    continue

                // Определяем ориентацию и длину корабля
                var horiz = false
                var len = 1

                var hasRight = (x + 1 < board.cols &&
                                gameBoard.myCellStatusAt(x + 1, y) === 1)

                var hasBottom = (y + 1 < board.rows &&
                                 gameBoard.myCellStatusAt(x, y + 1) === 1)

                if (hasRight) {
                    horiz = true
                    len = 1
                    xx = x + 1
                    while (xx < board.cols &&
                           gameBoard.myCellStatusAt(xx, y) === 1) {
                        ++len
                        ++xx
                    }

                    for (k = 0; k < len; ++k) {
                        visited[y][x + k] = true
                    }

                    foundShips.push({
                        len: len,
                        x: x,
                        y: y,
                        horizontal: true
                    })
                } else if (hasBottom) {
                    // Вертикальный корабль
                    horiz = false
                    len = 1
                    yy = y + 1
                    while (yy < board.rows &&
                           gameBoard.myCellStatusAt(x, yy) === 1) {
                        ++len
                        ++yy
                    }

                    for (k = 0; k < len; ++k) {
                        visited[y + k][x] = true
                    }

                    foundShips.push({
                        len: len,
                        x: x,
                        y: y,
                        horizontal: false
                    })
                } else {
                    // Одиночный корабль (длина 1)
                    visited[y][x] = true
                    foundShips.push({
                        len: 1,
                        x: x,
                        y: y,
                        horizontal: true
                    })
                }
            }
        }

        // Сортируем найденные корабли
        foundShips.sort(function(a, b) {
            if (b.len !== a.len)
                return b.len - a.len
            if (a.y !== b.y)
                return a.y - b.y
            return a.x - b.x
        })

        for (var i = 0; i < shipRepeater.count; ++i) {
            var shipItem = shipRepeater.itemAt(i)
            var expectedLen = shipDockLayout.get(i).len

            var found = null
            for (k = 0; k < foundShips.length; ++k) {
                if (foundShips[k].len === expectedLen) {
                    found = foundShips[k]
                    foundShips.splice(k, 1)
                    break
                }
            }

            if (found) {
                shipItem.suppressMoveAnim = true

                shipItem.placed = true
                shipItem.gridX = found.x
                shipItem.gridY = found.y
                shipItem.horizontal = found.horizontal

                shipItem.width  = shipItem.horizontal
                                    ? shipItem.shipLength * shipItem.cellSize
                                    : shipItem.cellSize
                shipItem.height = shipItem.horizontal
                                    ? shipItem.cellSize
                                    : shipItem.shipLength * shipItem.cellSize

                shipItem.x = board.x + found.x * board.cellSize
                shipItem.y = board.y + found.y * board.cellSize

                shipItem.suppressMoveAnim = false
            } else {
                // Корабль не найден на поле — возвращаем в док
                var homeSpot = shipDockLayout.get(i)

                shipItem.suppressMoveAnim = true

                shipItem.placed = false
                shipItem.gridX = -1
                shipItem.gridY = -1
                shipItem.horizontal = true

                shipItem.width  = shipItem.shipLength * shipItem.cellSize
                shipItem.height = shipItem.cellSize

                shipItem.x = placementScreen.dockAbsX + homeSpot.ox
                shipItem.y = placementScreen.dockAbsY + homeSpot.oy

                shipItem.suppressMoveAnim = false
            }
        }
    }
}
