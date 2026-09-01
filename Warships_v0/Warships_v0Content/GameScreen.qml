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
            visible: placementBG.playbackState !== MediaPlayer.PlayingState
        }

        Component.onCompleted: play()
    }

    Item {
        id: gameContent
        anchors.fill: parent
        enabled: false
        z: 5

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

        Row {
            spacing: 200
            anchors.centerIn: parent
            z: 20

            // ================= ВАШЕ ПОЛЕ (СЛЕВА) =================
            Column {
                spacing: 8

                Text {
                    text: "ВАШЕ ПОЛЕ"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#C1C9CC"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    id: myBoard
                    width: 10 * 50
                    height: 10 * 50
                    color: "#162433"
                    opacity: 0.3
                    border.color: "#C1C9CC"
                    border.width: 3

                    property int cols: 10
                    property int rows: 10
                    property int cellSize: 50

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
                        }
                    }

                    // логические клетки: показываем корабли игрока
                    Repeater {
                        model: myBoard.rows * myBoard.cols
                        Rectangle {
                            width: myBoard.cellSize
                            height: myBoard.cellSize
                            x: (index % myBoard.cols) * myBoard.cellSize
                            y: Math.floor(index / myBoard.cols) * myBoard.cellSize

                            // отрисовка статусов клеток
                            color: {
                                var revision = gameBoard.boardRevision

                                var col = index % myBoard.cols
                                var row = Math.floor(index / myBoard.cols)
                                var st = gameBoard.myCellStatusAt(col, row)

                                // 0 Clean, 1 Ship, 2 Shot, 3 Damaged, 4 Killed
                                if (st === 0) return "transparent"
                                if (st === 1) return "#90CAF9"
                                if (st === 2) return "#B0BEC5"
                                if (st === 3) return "#FF7043"
                                if (st === 4) return "#D32F2F"

                                return "transparent"
                            }
                            border.color: "transparent";
                        }
                    }
                }
            }

            // ================= ПОЛЕ ПРОТИВНИКА (СПРАВА) =================
            Column {
                spacing: 8

                Text {
                    text: "ПОЛЕ ПРОТИВНИКА"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#C1C9CC"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    id: enemyBoard
                    width: 10 * 50
                    height: 10 * 50
                    color: "#162433"
                    opacity: 0.3
                    border.color: "#C1C9CC"
                    border.width: 3

                    property int cols: 10
                    property int rows: 10
                    property int cellSize: 50

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
                        }
                    }

                    // клетки для стрельбы по врагу
                    Repeater {
                        model: enemyBoard.rows * enemyBoard.cols
                        Rectangle {
                            id: enemyCell
                            width: enemyBoard.cellSize
                            height: enemyBoard.cellSize
                            x: (index % enemyBoard.cols) * enemyBoard.cellSize
                            y: Math.floor(index / enemyBoard.cols) * enemyBoard.cellSize

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
            }
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

    //Текстовая плашка "ИГРА НАЧАЛАСЬ!"

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
