import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Warships 1.0
import QtMultimedia

Rectangle {
    id: gameScreen
    anchors.fill: parent

    Video{
        id: gamescreenBG
        anchors.fill: parent
        source: "images/SeaAnimated.mp4"
        playbackRate: 1
        fillMode: VideoOutput.PreserveAspectCrop
        loops: MediaPlayer.Infinite
        z: 0

        Image {
            anchors.fill: parent
            source: "images/Sea.jpg"
            fillMode: Image.PreserveAspectCrop
            visible: gamescreenBG.playbackState !== MediaPlayer.PlayingState
        }

        Component.onCompleted: play()    
    }

    Item {
        id: gameContent
        anchors.fill: parent
        enabled: false
        z: 5

        // анимация взрыва (компонент)
        Component {
            id: explosionComponent

            Image {
                id: explosionImg
                source: "images/ExplosionList.png"
                z: 30

                property int cellSize: 50
                property int frameIndex: 0

                property int frameSize: 256 // в исходном файле

                width: cellSize
                height: cellSize

                // вырезание кадра
                sourceClipRect: Qt.rect(
                    (frameIndex % 5) * frameSize,
                    Math.floor(frameIndex / 5) * frameSize,
                    frameSize,
                    frameSize
                )

                // Переход между кадрами
                NumberAnimation {
                    target: explosionImg
                    property: "frameIndex"
                    from: 0
                    to: 24
                    duration: 500
                    running: true
                    loops: 1
                }

                // уничтожение после анимации
                Timer {
                    interval: 500
                    running: true
                    repeat: false
                    onTriggered: explosionImg.destroy()
                }
            }
        }

        // Функция запуска взрыва
        function playExplosion(board, x, y){
            var explosion = explosionComponent.createObject(board)
            explosion.x = x * board.cellSize
            explosion.y = y * board.cellSize
            explosion.cellSize = board.cellSize
        }

        // Функция поиска кораблей для отрисовки
        function findShipsOnBoard() {
            var ships = []
            var visited = []
            var xx, yy, k

            for (yy = 0; yy < myBoard.rows; ++yy) {
                visited[yy] = []
                for (xx = 0; xx < myBoard.cols; ++xx) {
                    visited[yy][xx] = false
                }
            }

            for (var y = 0; y < myBoard.rows; ++y) {
                for (var x = 0; x < myBoard.cols; ++x) {
                    var status = gameBoard.myCellStatusAt(x, y)
                    if (status !== 1)
                        continue

                    if (visited[y][x])
                        continue

                    var horiz = false
                    var len = 1

                    var hasRight = (x + 1 < myBoard.cols &&
                        gameBoard.myCellStatusAt(x + 1, y) === 1)
                    var hasBottom = (y + 1 < myBoard.rows &&
                        gameBoard.myCellStatusAt(x, y + 1) === 1)

                    if (hasRight) {
                        horiz = true
                        len = 1
                        xx = x + 1
                        while (xx < myBoard.cols &&
                        gameBoard.myCellStatusAt(xx, y) === 1) {
                            ++len
                            ++xx
                        }

                        for (k = 0; k < len; ++k) {
                            visited[y][x + k] = true
                        }

                        ships.push({
                            len: len,
                            x: x,
                            y: y,
                            horizontal: true
                        })
                        } else if (hasBottom) {
                            horiz = false
                            len = 1
                            yy = y + 1
                            while (yy < myBoard.rows &&
                            gameBoard.myCellStatusAt(x, yy) === 1) {
                                ++len
                                ++yy
                            }

                        for (k = 0; k < len; ++k) {
                            visited[y + k][x] = true
                        }

                        ships.push({
                            len: len,
                            x: x,
                            y: y,
                            horizontal: false
                        })
                        } else {
                            visited[y][x] = true
                            ships.push({
                                len: 1,
                                x: x,
                                y: y,
                                horizontal: true
                            })
                        }
                    }
                }

                return ships
        }

        Rectangle {
            id: player1Box
            height: 80
            width: height * 3.64
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.top: parent.top
            anchors.topMargin: 30
            color: "transparent"
            z: 30

            Image {
                anchors.fill: parent
                source: "images/ButtonBG.png"
                fillMode: Image.Stretch
                z: 0
            }

            Text {
                anchors.centerIn: parent
                text: {
                    if (gameController.gamemode === GameController.Local)
                        return networkManager.playerName;

                    return "Вы"
                }
                font.pixelSize: 28
                font.bold: true
                color: "#C1C9CC"
                z: 10
            }
        }

        Rectangle {
            id: player2Box
            height: 80
            width: height * 3.64
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.top: parent.top
            anchors.topMargin: 30
            color: "transparent"
            z: 30

            Image {
                anchors.fill: parent
                source: "images/ButtonBG.png"
                fillMode: Image.Stretch
                z: 0
            }

            Text {
                anchors.centerIn: parent
                text: {
                    if (gameController.gamemode === GameController.Local)
                        return networkManager.enemyName();

                    return "Компьютер"
                }
                font.pixelSize: 28
                font.bold: true
                color: "#C1C9CC"
                z: 10
            }
        }

            // ================= ВАШЕ ПОЛЕ (СЛЕВА) =================
                Rectangle {
                    id: myBoard
                    width: 10 * 50
                    height: 10 * 50
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: -300
                    color: "transparent"
                    border.color: "#C1C9CC"
                    border.width: 3
                    z: 20

                    property int cols: 10
                    property int rows: 10
                    property int cellSize: 50

                    Rectangle {
                        anchors.fill: parent
                        color: "#162433"
                        opacity: 0.3
                        z: 0
                    }

                    // фон-сетка
                    Repeater {
                        model: myBoard.rows
                        Rectangle {
                            width: myBoard.width
                            height: myBoard.cellSize
                            y: index * myBoard.cellSize
                            color: "transparent"
                            border.color: "#C1C9CC"
                            border.width: 1
                            z: 10
                        }
                    }

                    Repeater {
                        model: myBoard.cols
                        Rectangle {
                            width: myBoard.cellSize
                            height: myBoard.height
                            x: index * myBoard.cellSize
                            color: "transparent"
                            border.color: "#C1C9CC"
                            border.width: 1
                            z: 10
                        }
                    }

                    Repeater {
                        id: myShipsRepeater
                        model: gameContent.findShipsOnBoard()

                        delegate: Item {
                            width: modelData.horizontal
                                ? modelData.len * myBoard.cellSize
                                : myBoard.cellSize
                            height: modelData.horizontal
                                ? myBoard.cellSize
                                : modelData.len * myBoard.cellSize
                            x: modelData.x * myBoard.cellSize
                            y: modelData.y * myBoard.cellSize
                            z: 15

                            Image {
                                anchors.centerIn: parent
                                source: "images/ships/ship" + modelData.len + ".png"

                                width: modelData.len * myBoard.cellSize - 5
                                height: myBoard.cellSize - 5

                                rotation: modelData.horizontal ? 0 : 90
                            }
                        }
                    }

                    Repeater {
                        model: myBoard.rows * myBoard.cols
                        delegate: Rectangle {
                            width: myBoard.cellSize
                            height: myBoard.cellSize
                            x: (index % myBoard.cols) * myBoard.cellSize
                            y: Math.floor(index / myBoard.cols) * myBoard.cellSize
                            z: 25

                            property int lastStatus: {
                                var col = index % myBoard.cols
                                var row = Math.floor(index / myBoard.cols)
                                return gameBoard.myCellStatusAt(col, row)
                            }

                            Connections {
                                target: gameBoard
                                function onBoardChanged() {
                                    var col = index % myBoard.cols
                                    var row = Math.floor(index / myBoard.cols)
                                    var st = gameBoard.myCellStatusAt(col, row)

                                    if(lastStatus === 1 && (st === 3 || st === 4)){
                                        gameContent.playExplosion(myBoard, col, row)
                                    }
                                    lastStatus = st
                                }
                            }

                            // отрисовка статусов клеток
                            color: {
                                var revision = gameBoard.boardRevision

                                var col = index % myBoard.cols
                                var row = Math.floor(index / myBoard.cols)
                                var st = gameBoard.myCellStatusAt(col, row)

                                // 0 Clean, 1 Ship, 2 Shot, 3 Damaged, 4 Killed
                                if (st === 2) return "#B0BEC5"
                                if (st === 3) return "#FF7043"
                                if (st === 4) return "#D32F2F"

                                return "transparent"
                            }
                            border.color: "transparent";
                        }
                    }
                }

                Text {
                    text: "ВАШЕ ПОЛЕ"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#C1C9CC"
                    anchors.horizontalCenter: myBoard.horizontalCenter
                    anchors.bottom: myBoard.top
                    anchors.bottomMargin: 10
                    z: 20
                }

            // ================= ПОЛЕ ПРОТИВНИКА (СПРАВА) =================
                Rectangle {
                    id: enemyBoard
                    width: 10 * 50
                    height: 10 * 50
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.verticalCenterOffset: 50
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 300
                    color: "transparent"
                    border.color: "#C1C9CC"
                    border.width: 3
                    z: 20

                    property int cols: 10
                    property int rows: 10
                    property int cellSize: 50

                    Rectangle {
                        anchors.fill: parent
                        color: "#162433"
                        opacity: 0.3
                        z: 0
                    }

                    // фон-сетка
                    Repeater {
                        model: enemyBoard.rows
                        Rectangle {
                            width: enemyBoard.width
                            height: enemyBoard.cellSize
                            y: index * enemyBoard.cellSize
                            color: "transparent"
                            border.color: "#C1C9CC"
                            border.width: 1
                            z: 10
                        }
                    }

                    Repeater {
                        model: enemyBoard.cols
                        Rectangle {
                            width: enemyBoard.cellSize
                            height: enemyBoard.height
                            x: index * enemyBoard.cellSize
                            color: "transparent"
                            border.color: "#C1C9CC"
                            border.width: 1
                            z: 10
                        }
                    }

                    // клетки для стрельбы по врагу
                    Repeater {
                        model: enemyBoard.rows * enemyBoard.cols
                        delegate: Rectangle {
                            id: enemyCell
                            width: enemyBoard.cellSize
                            height: enemyBoard.cellSize
                            x: (index % enemyBoard.cols) * enemyBoard.cellSize
                            y: Math.floor(index / enemyBoard.cols) * enemyBoard.cellSize
                            z: 15

                            property int lastStatus: {
                                var col = index % enemyBoard.cols
                                var row = Math.floor(index / enemyBoard.cols)
                                return gameBoard.enemyCellStatusAt(col, row)
                            }

                            Connections {
                                target: gameBoard
                                function onBoardChanged() {
                                    var col = index % enemyBoard.cols
                                    var row = Math.floor(index / enemyBoard.cols)
                                    var st = gameBoard.enemyCellStatusAt(col, row)

                                    if (lastStatus === 0 && (st === 3 || st === 4)) {
                                        gameContent.playExplosion(enemyBoard, col, row)
                                    }

                                    lastStatus = st
                                }
                            }

                            // отрисовка состояния вражеских клеток
                            color: {
                                var revision = gameBoard.boardRevision

                                var col = index % enemyBoard.cols
                                var row = Math.floor(index / enemyBoard.cols)
                                var st = gameBoard.enemyCellStatusAt(col, row)

                                // 0 Clean, 2 Shot, 3 Damaged, 4 Killed
                                if (st === 0) return "transparent"
                                if (st === 2) return "#B0BEC5"
                                if (st === 3) return "#FF7043"
                                if (st === 4) return "#D32F2F"

                                return "transparent"
                            }
                            border.color: "transparent"

                            MouseArea {
                                anchors.fill: parent
                                enabled: gameController.turn === GameController.MyTurn
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: {
                                    console.log("Enemy cell clicked")
                                    var cellX = index % enemyBoard.cols
                                    var cellY = Math.floor(index / enemyBoard.cols)

                                    gameController.playerShootsAt(cellX, cellY);
                                }
                            }
                        }
                    }
                }

                Text {
                    text: "ПОЛЕ ПРОТИВНИКА"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#C1C9CC"
                    anchors.horizontalCenter: enemyBoard.horizontalCenter
                    anchors.bottom: enemyBoard.top
                    anchors.bottomMargin: 10
                    z: 20
                }

                // Затемнение фона (5 прямоугольников)
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.bottom: myBoard.top
                    z: 3
                    color: "#162433"
                    opacity: 0.8
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: myBoard.bottom
                    anchors.bottom: parent.bottom
                    z: 3
                    color: "#162433"
                    opacity: 0.8
                }
                Rectangle {
                    anchors.left: parent.left
                    anchors.right: myBoard.left
                    anchors.top: myBoard.top
                    anchors.bottom: myBoard.bottom
                    z: 3
                    color: "#162433"
                    opacity: 0.8
                }
                Rectangle {
                    anchors.left: myBoard.right
                    anchors.right: enemyBoard.left
                    anchors.top: myBoard.top
                    anchors.bottom: myBoard.bottom
                    z: 3
                    color: "#162433"
                    opacity: 0.8
                }
                Rectangle {
                    anchors.left: enemyBoard.right
                    anchors.right: parent.right
                    anchors.top: enemyBoard.top
                    anchors.bottom: enemyBoard.bottom
                    z: 3
                    color: "#162433"
                    opacity: 0.8
                }
    }

    // Блюр
    MultiEffect {
        id: blurEffect
        anchors.fill: gameContent
        source: gameContent
        blurEnabled: true
        blurMax: 32
        autoPaddingEnabled: true
        z: 50

        property real amount: 0.0
        blur: amount
    }

    // Затемнение фона
    Rectangle {
        id: dimOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: 0.0
        z: 50
    }

    Rectangle {
        id: introBox
        width: 500
        height: 200
        color: "transparent"
        opacity: 0.0
        anchors.horizontalCenter: parent.horizontalCenter
        y: gameScreen.height / 2 - height / 2
        z: 100

        Image {
            anchors.fill: parent
            source: "images/Logo_BG.png"
            fillMode: Image.Stretch
            z: 0
        }

        Text {
            id: introText
            anchors.centerIn: parent
            topPadding: 75
            text: "Игра началась!"
            font.pixelSize: 30
            font.bold: true
            color: "#C1C9CC"
            z: 1
        }
    }

    // ===== Анимация появления экрана боя (при входе на страницу) =====
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
        ScriptAction { script: introBox.anchors.top = gameScreen.top }
        ScriptAction { script: introBox.anchors.topMargin = 10 }

        PauseAnimation { duration: 250 }

        NumberAnimation { target: introText; property: "opacity"; from: 1.0; to: 0.0; duration: 250 }

        ScriptAction {
            script: {
                var turnText = "Неизвестное состояние"

                if (gameController.turn === GameController.MyTurn)
                    turnText = "Ваш ход"
                else if (gameController.turn === GameController.EnemyTurn)
                    turnText = "Ход противника"
                else if (gameController.turn === GameController.GameOver_PlayerWon)
                    turnText = "Победа!"
                else if (gameController.turn === GameController.GameOver_PlayerLost)
                    turnText = "Поражение"

                introText.text = turnText
            }
        }

        NumberAnimation { target: introText; property: "opacity"; from: 0.0; to: 1.0; duration: 500 }
    }

    Connections {
        target: gameController
        function onTurnChanged() {
            var turnText = "Неизвестное состояние"

            if (gameController.turn === GameController.MyTurn)
                turnText = "Ваш ход"
            else if (gameController.turn === GameController.EnemyTurn)
                turnText = "Ход противника"
            else if (gameController.turn === GameController.GameOver_PlayerWon)
                turnText = "Победа!"
            else if (gameController.turn === GameController.GameOver_PlayerLost)
                turnText = "Поражение"

            introText.text = turnText
        }
    }
}
