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

    Text {
        id: title
        text: "WARSHIPS"
        font.pointSize: 28
        font.bold: true
        font.family: "Verdana"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: 50
    }

    GridLayout {
        id: grid
        columns: 2
        anchors.centerIn: parent
        columnSpacing: 10
        rowSpacing: 10

        Repeater {
            model: ["Одиночная игра", "Сетевая игра", "Магазин", "Выйти"]

            Button {
                text: modelData
                Layout.preferredWidth: 200
                Layout.preferredHeight: 60
                font.pointSize: 16
                font.bold: true

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
