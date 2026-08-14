import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: networkPopup
    width: 420
    height: 360
    modal: true
    focus: true
    anchors.centerIn: Overlay.overlay

    property string errorText: ""
    property bool showPlayers: false

    // временно, потом из сервера возьмем
    ListModel {
        id: playersModel

        ListElement { playerName: "Игрок 1" }
        ListElement { playerName: "Игрок 2" }
        ListElement { playerName: "Игрок 3" }
    }

    Popup {
        id: statusPopup

        width: 400
        height: 240
        anchors.centerIn: Overlay.overlay

        modal: true
        closePolicy: Popup.NoAutoClose

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20
            spacing: 12

            BusyIndicator {
                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Ждём второго игрока..."
                font.bold: true
                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 10

        Text {
            text: networkPopup.showPlayers
                  ? "Выберите игрока"
                  : "Введите имя"

            font.pixelSize: 20
            font.bold: true

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 5
        }

        StackLayout {
            id: pages

            Layout.fillWidth: true
            Layout.fillHeight: true

            currentIndex: networkPopup.showPlayers ? 1 : 0

            // Страница 0: ввод имени
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.centerIn: parent
                    width: 300
                    spacing: 12

                    TextField {
                        id: nameInput

                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 250
                        Layout.preferredHeight: 40

                        placeholderText: "Введите имя"
                        maximumLength: 20

                        onTextChanged: {
                            networkPopup.errorText = ""
                        }
                    }

                    Text {
                        text: networkPopup.errorText
                        color: "#D32F2F"
                        visible: text.length > 0

                        Layout.alignment: Qt.AlignHCenter
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

                            enabled: nameInput.text.trim().length > 0

                            onClicked: {
                                var name = nameInput.text.trim()

                                if (name.length === 0) {
                                    networkPopup.errorText =
                                            "Введите имя игрока"
                                    nameInput.forceActiveFocus()
                                    return
                                }

                                gameController.playerName = name

                                console.log(
                                    "<NetworkPopup> имя игрока:",
                                    gameController.playerName
                                )

                                playersList.currentIndex = -1
                                networkPopup.showPlayers = true
                            }
                        }

                        Button {
                            text: "Отмена"
                            Layout.preferredWidth: 110

                            onClicked: {
                                networkPopup.close()
                            }
                        }
                    }
                }
            }

            // Страница 1: список игроков
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 12

                    ListView {
                        id: playersList

                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        clip: true
                        spacing: 4

                        model: playersModel

                        delegate: Rectangle {
                            width: playersList.width
                            height: 44
                            radius: 6

                            color: ListView.isCurrentItem
                                   ? "#90CAF9"
                                   : "#EEEEEE"

                            border.color: ListView.isCurrentItem
                                          ? "#1976D2"
                                          : "#BDBDBD"

                            Text {
                                anchors.centerIn: parent
                                text: playerName
                                color: "#000000"
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    playersList.currentIndex = index

                                    console.log(
                                        "<NetworkPopup> выбран игрок:",
                                        playerName,
                                        "index:",
                                        index
                                    )
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            visible: playersList.count === 0
                            text: "Доступных игроков нет"
                            color: "#757575"
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 15

                        Button {
                            text: "Подключиться"
                            Layout.preferredWidth: 130

                            enabled: playersList.currentIndex >= 0

                            onClicked: {
                                if (playersList.currentIndex < 0)
                                    return

                                var selectedPlayer =
                                        playersList.currentItem.playerName

                                console.log(
                                    "<NetworkPopup> подключение к игроку:",
                                    selectedPlayer
                                )

                                statusPopup.open()
                            }
                        }

                        Button {
                            text: "Назад"
                            Layout.preferredWidth: 110

                            onClicked: {
                                networkPopup.showPlayers = false
                                playersList.currentIndex = -1
                            }
                        }
                    }
                }
            }
        }
    }

    onClosed: {
        statusPopup.close()
        showPlayers = false
        errorText = ""
        playersList.currentIndex = -1
        nameInput.clear()
    }
}