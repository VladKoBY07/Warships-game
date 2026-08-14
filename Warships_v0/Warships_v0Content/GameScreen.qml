import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Warships 1.0

Rectangle {
    id: gameScreen
    anchors.fill: parent
    color: "#ffffff"

    Item {
        id: gameContent
        anchors.fill: parent
        enabled: false

        Rectangle {
            id: player1Box
            width: 240
            height: 80
            radius: 10
            color: "#F5F5F5"
            border.color: "#BDBDBD"
            border.width: 1
            anchors.left: parent.left
            anchors.leftMargin: 30
            anchors.top: parent.top
            anchors.topMargin: 30

            Text {
                anchors.centerIn: parent
                text: {
                    if (gameController.gamemode === GameController.Local)
                        return gameController.playerName

                    return "Вы"
                }
                font.pixelSize: 28
                font.bold: true
                color: "#000000"
            }
        }

        Rectangle {
            id: player2Box
            width: 240
            height: 80
            radius: 10
            color: "#F5F5F5"
            border.color: "#BDBDBD"
            border.width: 1
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.top: parent.top
            anchors.topMargin: 30

            Text {
                anchors.centerIn: parent
                text: {
                    if (gameController.gamemode === GameController.Local)
                        return "Игрок 2" // имя из сервера

                    return "Компьютер"
                }
                font.pixelSize: 28
                font.bold: true
                color: "#000000"
            }
        }

        Row {
            spacing: 200
            anchors.centerIn: parent

            // ================= ВАШЕ ПОЛЕ (СЛЕВА) =================
            Column {
                spacing: 8

                Text {
                    text: "ВАШЕ ПОЛЕ"
                    font.bold: true
                    font.pixelSize: 16
                    color: "#616161"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    id: myBoard
                    width: 10 * 40
                    height: 10 * 40
                    color: "#FFFFFF"
                    border.color: "#BDBDBD"
                    border.width: 1

                    property int cols: 10
                    property int rows: 10
                    property int cellSize: 40

                    // фон-сетка
                    Repeater {
                        model: myBoard.rows
                        Rectangle {
                            width: myBoard.width
                            height: myBoard.cellSize
                            y: index * myBoard.cellSize
                            color: "transparent"
                            border.color: "#EEEEEE"
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
                            border.color: "#EEEEEE"
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
                    color: "#616161"
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    id: enemyBoard
                    width: 10 * 40
                    height: 10 * 40
                    color: "#FFFFFF"
                    border.color: "#BDBDBD"
                    border.width: 1

                    property int cols: 10
                    property int rows: 10
                    property int cellSize: 40

                    // фон-сетка
                    Repeater {
                        model: enemyBoard.rows
                        Rectangle {
                            width: enemyBoard.width
                            height: enemyBoard.cellSize
                            y: index * enemyBoard.cellSize
                            color: "transparent"
                            border.color: "#EEEEEE"
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
                            border.color: "#EEEEEE"
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

        property real amount: 0.0
        blur: amount
    }

    // Затемнение фона
    Rectangle {
        id: dimOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: 0.0
    }

    //Текстовая плашка "ИГРА НАЧАЛАСЬ!"

    Rectangle {
        id: introBox
        width: 380
        height: 90
        radius: 10
        color: "#F5F5F5"
        border.color: "#BDBDBD"
        border.width: 1
        opacity: 0.0
        anchors.horizontalCenter: parent.horizontalCenter
        y: gameScreen.height / 2 - height / 2

        Text {
            anchors.centerIn: parent
            text: "Игра началась!"
            font.pixelSize: 30
            font.bold: true
            color: "#000000"
        }
    }

    // Плашка индикатора хода
    Rectangle {
        id: turnPlate
        width: 220
        height: 60
        radius: 10
        color: "#F5F5F5"
        border.color: "#BDBDBD"
        border.width: 1
        opacity: 0.0
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: introBox.bottom
        anchors.topMargin: 24

        Text {
            anchors.centerIn: parent

            text: {
                if (gameController.turn === GameController.MyTurn)
                    return "Ваш ход"

                if (gameController.turn === GameController.EnemyTurn)
                    return "Ход противника"

                if (gameController.turn === GameController.GameOver_PlayerWon)
                    return "Победа!"

                if (gameController.turn === GameController.GameOver_PlayerLost)
                    return "Поражение"

                return "Неизвестное состояние"
            }

            font.pixelSize: 20
            font.bold: true
            color: "#000000"
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
            to: 40
            duration: 500
            easing.type: Easing.InOutQuad
        }

        ParallelAnimation {
            NumberAnimation { target: blurEffect; property: "amount"; from: 1.0; to: 0.0; duration: 300; easing.type: Easing.InQuad }
            NumberAnimation { target: dimOverlay; property: "opacity"; from: 0.35; to: 0.0; duration: 300 }
        }

        ScriptAction { script: gameContent.enabled = true }
        ScriptAction { script: introBox.anchors.top = gameScreen.top }
        ScriptAction { script: introBox.anchors.topMargin = 40 }

        NumberAnimation { target: turnPlate; property: "opacity"; from: 0.0; to: 1.0; duration: 300 }

        PauseAnimation { duration: 3000 }
        NumberAnimation { target: introBox; property: "opacity"; from: 1.0; to: 0.0; duration: 500 }
    }
}
