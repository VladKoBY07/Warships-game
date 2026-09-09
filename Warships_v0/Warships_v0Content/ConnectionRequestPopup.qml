import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: connectionRequestPopup

    width: 550
    height: width / 3.5

    modal: true
    focus: true

    closePolicy: Popup.NoAutoClose

    parent: Overlay.overlay
    x: (Overlay.overlay.width - width) / 2  // По горизонтали по центру
    y: Overlay.overlay.height - height - 50  // По вертикали внизу с отступом

    property string requestedPlayerName: ""

    background: Rectangle {
        implicitWidth: connectionRequestPopup.width
        implicitHeight: connectionRequestPopup.height

        color: "transparent"

        Image {
            anchors.fill: parent
            source: "images/ButtonBG.png"
            fillMode: Image.Stretch
            z: 0
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10

        spacing: 5

        Text {
            text: "Запрос на подключение"
            color: "#C1C9CC"

            font.pixelSize: 20
            font.bold: true

            Layout.alignment: Qt.AlignHCenter
        }

        Text {
            text: "От игрока: " + connectionRequestPopup.requestedPlayerName
            color: "#C1C9CC"
            font.pixelSize: 20
            wrapMode: Text.NoWrap

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
                id: acceptRequestButton
                text: "Принять"
                contentItem: Text{
                    text: acceptRequestButton.text
                    color: "#C1C9CC"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                implicitWidth: 140
                implicitHeight: implicitWidth / 3.4

                leftPadding: acceptRequestButton.pressed ? 8 : 4
                topPadding: acceptRequestButton.pressed ? 8 : 4

                background: Image {
                    source: acceptRequestButton.pressed? "images/ButtonBG_pressed.png" :
                            (acceptRequestButton.hovered && acceptRequestButton.enabled)? "images/ButtonBG_hover.png" :
                                                "images/ButtonBG_not_pressed.png"
                    fillMode: Image.Stretch
                }

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
                id: rejectRequestButton
                text: "Отклонить"
                contentItem: Text{
                    text: rejectRequestButton.text
                    color: "#C1C9CC"
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                }
                implicitWidth: 140
                implicitHeight: implicitWidth / 3.4

                leftPadding: rejectRequestButton.pressed ? 8 : 4
                topPadding: rejectRequestButton.pressed ? 8 : 4

                background: Image {
                    source: rejectRequestButton.pressed? "images/ButtonBG_pressed.png" :
                            (rejectRequestButton.hovered && rejectRequestButton.enabled)? "images/ButtonBG_hover.png" :
                                                "images/ButtonBG_not_pressed.png"
                    fillMode: Image.Stretch
                }

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