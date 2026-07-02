import QtQuick
import QtQuick.Controls

Rectangle {
    id: startMenu
    anchors.fill: parent
    color: "#f0f4f8"

    Text {
        text: "WARSHIPS"
        font.pointSize: 28
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50
    }

    // Ряд кнопок по центру экрана
    Row {
        spacing: 30
        anchors.centerIn: parent

        Button {
            id: createGameButton
            text: "Создать игру"
            width: 180
            height: 50
        }

        Button {
            id: connectButton
            text: "Подключиться"
            width: 180
            height: 50
        }
    }
}
