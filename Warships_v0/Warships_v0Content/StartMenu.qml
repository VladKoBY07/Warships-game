import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Warships 1.0

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
                            console.log("<Главное меню> Выбрана одиночная игра")
                            gameController.start_PvAI()
                            stackView.push("PlacementScreen.qml")
                            break;
                        case 1:
                            console.log("<Главное меню> Выбрана сетевая игра")
                            gameController.start_Local()
                            // TODO: ввод имени -> открытие окна серверов (сделать окно серверов)
                            networkPopup.open()
                            break;
                        case 2:
                            console.log("<Главное меню> Выбран магазин")
                            // TODO: переход на страницу магазина
                            break;
                        case 3:
                            console.log("<Главное меню> Выход из игры")
                            Qt.quit()
                            break;
                    }
                }
            }
        }
    }
}
