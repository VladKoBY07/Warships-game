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
            border.color: "#BDBDBD"
            border.width: 2
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
                anchors.topMargin: 8
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

        Text {
            visible: placementScreen.currentGamemode
                     === GameController.Local

            anchors.top: readyButton.bottom
            anchors.topMargin: 12
            anchors.horizontalCenter: board.horizontalCenter
            z: 10

            text: {
                if (placementScreen.currentGamemode
                    !== GameController.Local) {
                    return ""
                }

                return placementScreen.opponentReady
                       ? "Соперник готов"
                       : "Соперник не готов"
            }

            color: placementScreen.opponentReady
                   ? "#2E7D32"
                   : "#F57C00"

            font.bold: true
            font.pixelSize: 18
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
                    // Ждём соперника
                }
            }
        }

        Button {
            id: clearButton
            text: "Очистить"
            anchors.top: readyButton.bottom
            anchors.topMargin: 12
            anchors.horizontalCenter: board.horizontalCenter
            z: 10
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
            placementScreen.stackView.push(
                Qt.resolvedUrl("GameScreen.qml")
            )
        }
    }
}
