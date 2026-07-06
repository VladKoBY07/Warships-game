import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Rectangle {
    id: gameScreen
    anchors.fill: parent
    color: "#ffffff"

    //Todo: прописать данные полученные он PlacementScreen
    //Todo: Это строка состояния хода вы должны подключить её к логике
    //можете менять текст в qml так -> gameScreen.turnText = "Ход противника"
    property string turnText: "Ваш ход"

    // TODO: прописать в gameboard.cpp функцию получения состояния поля
    // противника, через сервер например getEnemyBoardState()

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

                    Grid {
                        id: myGrid
                        anchors.fill: parent
                        rows: 10
                        columns: 10

                        Repeater {
                            model: 100
                            Rectangle {
                                width: 40
                                height: 40
                                border.color: "#EEEEEE"
                                border.width: 1
                                // На нашем поле корабли видны
                                // TODO: перенести расстановку кораблей с той страницы сюда
                            }
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

                    Grid {
                        id: enemyGrid
                        anchors.fill: parent
                        rows: 10
                        columns: 10

                        Repeater {
                            model: 100
                            Rectangle {
                                id: enemyCell
                                width: 40
                                height: 40
                                border.color: "#EEEEEE"
                                border.width: 1
                                // Поле противника для игрока визуально ВСЕГДА пустое —
                                // корабли противника (enemyBoardState) здесь не отображаются,
                                // видны только результаты выстрелов (попадание/промах).
                                color: enemyMouse.pressed ? "#F44336" : "#FFFFFF" //не знаю нужно ли (перекрашивает в крастный при нажатии)

                                MouseArea { // нужна для обработки выстрелов
                                    id: enemyMouse
                                    anchors.fill: parent
                                    //onClicked: {
                                        // TODO: прописать в gameboard.cpp функцию выстрела,
                                        // например gameBoard.shoot(x, y), возвращающую результат
                                        // (промах / попадание / убит корабль), и по этому результату
                                        // менять цвет клетки на постоянной основе (а не только по pressed),
                                        // а также передавать ход второму игроку (обновлять turnText).
                                    //}
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
