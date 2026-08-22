import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: connectionRequestPopup

    width: 380
    height: 220

    modal: true
    focus: true

    closePolicy: Popup.NoAutoClose

    anchors.centerIn: Overlay.overlay

    property string requestedPlayerName: ""

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20

        spacing: 15

        Text {
            text: "Запрос на подключение"

            font.pixelSize: 20
            font.bold: true

            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: connectionRequestPopup.requestedPlayerName
                  + " хочет подключиться к вам"

            wrapMode: Text.WordWrap

            horizontalAlignment: Text.AlignHCenter

            Layout.fillWidth: true
        }

        Item {
            Layout.fillHeight: true
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 15

            Button {
                text: "Принять"

                Layout.preferredWidth: 110

                onClicked: {
                    console.log(
                        "<ConnectionRequestPopup> Принят запрос от:",
                        connectionRequestPopup.requestedPlayerName
                    )

                    networkManager.acceptConnection()

                    connectionRequestPopup.close()
                }
            }

            Button {
                text: "Отклонить"

                Layout.preferredWidth: 110

                onClicked: {
                    console.log(
                        "<ConnectionRequestPopup> Отклонён запрос от:",
                        connectionRequestPopup.requestedPlayerName
                    )

                    networkManager.rejectConnection()

                    connectionRequestPopup.close()
                }
            }
        }
    }

    onClosed: {
        requestedPlayerName = ""
    }
}