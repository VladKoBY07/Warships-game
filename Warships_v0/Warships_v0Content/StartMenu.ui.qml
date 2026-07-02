import QtQuick
import QtQuick.Controls

Rectangle {
    id: startMenu
    anchors.fill: parent
    color: "#f0f4f8"

    Text {
        id: title
        text: "WARSHIPS"
        font.pointSize: 28
        font.bold: true
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50
        font.family: "Verdana"
    }

    Grid {
        id: grid
        width: parent.width / 2
        height: parent.height / 3
        property int spacing: 10
        columnSpacing: spacing
        rowSpacing: spacing
        rows: 2
        columns: 2
        anchors.centerIn: parent

        Button {
            id: button1
            text: qsTr("Одиночная игра")
            font.bold: true
            font.pointSize: 24
            width: parent.width / 2 - spacing
            height: (parent.height - spacing) / 2
        }

        Button {
            id: button2
            text: qsTr("Сетевая игра")
            font.bold: true
            font.pointSize: 24
            width: parent.width / 2 - spacing
            height: (parent.height - spacing) / 2
        }

        Button {
            id: button3
            text: qsTr("Магазин")
            font.pointSize: 24
            font.bold: true
            width: parent.width / 2 - spacing
            height: (parent.height - spacing) / 2
        }

        Button {
            id: button4
            text: qsTr("Выйти из игры")
            font.pointSize: 24
            font.bold: true
            width: parent.width / 2 - spacing
            height: (parent.height - spacing) / 2
        }
    }

    // Ряд кнопок по центру экрана
}
