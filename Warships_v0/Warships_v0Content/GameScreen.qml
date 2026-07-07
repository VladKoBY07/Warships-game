import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Warships 1.0

Rectangle {
    id: gameScreen
    anchors.fill: parent
    color: "#ffffff"

    // строка состояния боя
    property string turnText: "Ваш ход"

    // TODO: прописать в gameboard.cpp функцию получения состояния поля
    // противника, через сервер например getEnemyBoardState()
    // Tip: норм, сделаем после сервера, заготовка в функции отрисовки ниже

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
                text: "Игрок 1"
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
                text: "Игрок 2"
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
                                var col = index % myBoard.cols
                                var row = Math.floor(index / myBoard.cols)
                                var st = gameBoard.myCellStatusAt(col, row);

                                // 0 Clean, 1 Ship, 2 Shot, 3 Damaged, 4 Killed
                                if (st === 0)   return "transparent"; // Clean
                                if (st === 1)   return "#90CAF9";     // Ship (мои корабли)
                                if (st === 2)   return "#B0BEC5";     // Shot (промах противника)
                                if (st === 3)   return "#FF7043";     // Damaged (подбит)
                                if (st === 4)   return "#D32F2F";     // Killed (убит)
                                return "transparent";
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
                                var cx = index % enemyBoard.cols
                                var cy = Math.floor(index / enemyBoard.cols)
                                var st = gameBoard.enemyCellStatusAt(cx, cy);

                                console.log("enemyCell", cx, cy, "status", st);

                                // 0 Clean, 2 Shot, 3 Damaged, 4 Killed
                                if (st === 0)   return "transparent"; // ещё не стреляли
                                if (st === 2)   return "#B0BEC5";     // промах
                                if (st === 3)   return "#FF7043";     // попадание
                                if (st === 4)   return "#D32F2F";     // убит
                                return "transparent";
                            }
                            border.color: "transparent"

                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    console.log("Enemy cell clicked", index)
                                    var cellX = index % enemyBoard.cols
                                    var cellY = Math.floor(index / enemyBoard.cols)

                                    var result = 0; // Miss
                                    gameBoard.registerEnemyAnswer(cellX, cellY, result)

                                    // красим текущую клетку сразу, независимо от биндинга
                                    if (result === 0) {            // Miss
                                        enemyCell.color = "#B0BEC5"
                                    } else if (result === 1) {     // Hit
                                        enemyCell.color = "#FF7043"
                                    } else if (result === 2) {     // Kill
                                        enemyCell.color = "#D32F2F"
                                    }

                                    // текст хода
                                    if (result === 0) {
                                        gameScreen.turnText = "Ход противника"
                                    } else if (result === 1) {
                                        gameScreen.turnText = "Вы попали! Стреляйте снова"
                                    } else if (result === 2) {
                                        gameScreen.turnText = "Корабль потоплен!"
                                    }
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
            text: gameScreen.turnText
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
    }
}
