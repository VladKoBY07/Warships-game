import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: startMenu
    anchors.fill: parent
    color: "#f0f4f8"

    //Окно для сетевой игры (импортируем его как компонент)
    NetworkPopup {
       id: networkPopup
    }

    readonly property real refWidth: Screen.width
    readonly property real refHeight: Screen.height

    readonly property real ratio: Math.min(1, width / refWidth, height / refHeight)

    Text {
        id: title
        text: "WARSHIPS"
        font.pointSize: 20 * startMenu.ratio
        font.bold: true
        font.family: "Verdana"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50 * startMenu.ratio
    }

    GridLayout {
        id: grid
        columns: 2
        anchors.centerIn: parent
        columnSpacing: 12 * startMenu.ratio
        rowSpacing: 12 * startMenu.ratio

        Repeater {
            model: ["Одиночная игра", "Сетевая игра", "Магазин", "Выйти"]

            Button {
                id: menuButton
                text: modelData
                font.pointSize: 13.5 * startMenu.ratio
                font.bold: true

                Layout.preferredWidth: startMenu.refWidth * 0.1275 * startMenu.ratio
                Layout.preferredHeight: startMenu.refHeight * 0.0525 * startMenu.ratio

                TextMetrics {
                id: textMetrics
                text: modelData
                font: menuButton.font
                }

                onClicked: {
                    switch(index) {
                        case 0:
                            console.log("Запуск одиночной игры")
                            // TODO: логика перехода к игровому полю
                            // джиминишка предлагает сделать
                            // через Loader а не через stackView
                            break;
                        case 1:
                            console.log("Запуск сетевой игры")
                            networkPopup.open()
                            break;
                        case 2:
                            console.log("Открытие магазина")
                            // TODO: переход на страницу магазина
                            break;
                        case 3:
                            console.log("Выход из игры")
                            Qt.quit()
                            break;
                    }
                }
            }
        }
    }
}
