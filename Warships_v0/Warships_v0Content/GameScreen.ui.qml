import QtQuick
import QtQuick.Controls

Rectangle {
    id: gameScreen
    anchors.fill: parent
    color: "#ffffff"

    // Общий горизонтальный контейнер для двух полей
    Row {
        spacing: 40 // Расстояние между вашим полем и полем врага
        anchors.centerIn: parent

        // ================= ПОЛЕ ИГРОКА (СЛЕВА) =================
        Column {
            spacing: 5
            Text {
                text: "ВАШЕ ПОЛЕ"
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Grid {
                id: myGrid
                width: 250
                height: 250
                rows: 10
                columns: 10
                spacing: 1

                Repeater {
                    model: 100
                    Rectangle {
                        width: 24
                        height: 24
                        color: myMouse.pressed ? "#4CAF50" : "#e0e0e0" // Зеленеет при расстановке/нажатии
                        border.color: "#b0b0b0"
                        border.width: 1
                        MouseArea {
                            id: myMouse
                            anchors.fill: parent
                        }
                    }
                }
            }
        }

        // ================= ПОЛЕ ВРАГА (СПРАВА) =================
        Column {
            spacing: 5
            Text {
                text: "ПОЛЕ ВРАГА"
                font.bold: true
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Grid {
                id: enemyGrid
                width: 250
                height: 250
                rows: 10
                columns: 10
                spacing: 1

                Repeater {
                    model: 100
                    Rectangle {
                        width: 24
                        height: 24
                        color: enemyMouse.pressed ? "#F44336" : "#e0e0e0" // Краснеет при выстреле
                        border.color: "#b0b0b0"
                        border.width: 1
                        MouseArea {
                            id: enemyMouse
                            anchors.fill: parent
                        }
                    }
                }
            }
        }
    }
}
