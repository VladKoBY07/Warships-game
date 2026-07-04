import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: networkPopup
    width: 400
    height: 240
    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay

    // Окно загрузки
    Popup {
        id: statusPopup
        width: 400
        height: 240
        anchors.centerIn: Overlay.overlay
        modal: true
        closePolicy: Popup.NoAutoClose

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 10

            // возможно поменяю иконку загрузки
            BusyIndicator {
                running: true
                Layout.alignment: Qt.AlignHCenter
            }
            Text { text: "Ждём второго игрока..."; font.bold: true }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 20

        TextField {
            id: nameInput
            placeholderText: "Введите имя"
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 250
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            Button {
                text: "Создать"
                onClicked: {
                    console.log("запрос на создания сервера")
                    statusPopup.open()
                    //if (данные передались) {statusPopup.close()
                    //логика перехода к игровому полю
                    // джиминишка предлагает сделать
                    // через Loader а не через stackView}
                }
            }

            Button {
                text: "Подключиться"
                onClicked: {
                    console.log("запрос на подключение к серверу")
                    statusPopup.open()
                    //if (данные передались) {statusPopup.close()
                    //логика перехода к игровому полю
                    // джиминишка предлагает сделать
                    // через Loader а не через stackView}
                }
            }
        }
    }
}