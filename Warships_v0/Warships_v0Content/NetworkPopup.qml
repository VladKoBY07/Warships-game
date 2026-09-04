import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects

Popup {
    id: networkPopup

    width: 385
    height: 500

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape

    anchors.centerIn: Overlay.overlay

    background: Image {
        source: "images/LogoTable.png"
        fillMode: Image.Stretch
    }

    Overlay.modal: Rectangle {
        color: "#000000"
        opacity: 0.7
    }

    property string errorText: ""
    property bool showPlayers: false

    ConnectionRequestPopup {
        id: connectionRequestPopup
    }

    Popup {
        id: statusPopup

        width: 380
        height: 240

        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose

        anchors.centerIn: Overlay.overlay

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 20

            spacing: 12

            BusyIndicator {
                running: statusPopup.visible

                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Подключение..."
                color: "#C1C9CC"
                font.bold: true

                Layout.alignment: Qt.AlignHCenter
            }

            Text {
                text: "Ожидание ответа от игрока"
                color: "#C1C9CC"

                Layout.alignment: Qt.AlignHCenter
            }
        }
    }

    onOpened: {
        showPlayers = false
        errorText = ""

        connectionRequestPopup.close()
        statusPopup.close()

        playersList.currentIndex = -1

        nameInput.clear()
        nameInput.forceActiveFocus()
    }

    onClosed: {
        connectionRequestPopup.close()
        statusPopup.close()

        networkManager.stopDiscovery()

        showPlayers = false
        errorText = ""

        playersList.currentIndex = -1

        nameInput.clear()
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
            color: "#C1C9CC"

            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 5
            Layout.topMargin: 70
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
                        Layout.preferredWidth: 280
                        Layout.preferredHeight: 50

                        placeholderText: "Например: Джек Воробей"
                        color: "#C1C9CC"
                        font.pixelSize: 16
                        maximumLength: 15

                        onTextChanged: {
                            networkPopup.errorText = ""
                        }

                        Keys.onReturnPressed: {
                            acceptNameButton.clicked()
                        }

                        Keys.onEnterPressed: {
                            acceptNameButton.clicked()
                        }
                    }

                    Text {
                        text: networkPopup.errorText
                        color: "#D32F2F"

                        visible: text.length > 0

                        horizontalAlignment: Text.AlignHCenter

                        Layout.alignment: Qt.AlignHCenter
                        Layout.preferredWidth: 280

                        wrapMode: Text.WordWrap
                    }

                    Item {
                        Layout.fillHeight: true
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 5

                        Button {
                            id: acceptNameButton

                            text: "Принять"
                            font.pixelSize: 16
                            leftPadding: acceptNameButton.pressed ? 8 : 4
                            topPadding: acceptNameButton.pressed ? 8 : 4

                            implicitWidth: 140
                            implicitHeight: implicitWidth / 3.4

                            enabled: nameInput.text.trim().length > 0

                            onClicked: {
                                const name = nameInput.text.trim()

                                if (name.length === 0) {
                                    networkPopup.errorText =
                                        "Введите имя игрока"

                                    nameInput.forceActiveFocus()
                                    return
                                }

                                networkManager.playerName = name

                                console.log(
                                    "<NetworkPopup> имя игрока:",
                                    networkManager.playerName
                                )

                                playersList.currentIndex = -1

                                networkManager.startDiscovery()

                                networkPopup.showPlayers = true
                            }

                            background: Image {
                                source: acceptNameButton.pressed? "images/ButtonBG_pressed.png" :
                                        (acceptNameButton.hovered && acceptNameButton.enabled)? "images/ButtonBG_hover.png" :
                                                            "images/ButtonBG_not_pressed.png"
                                fillMode: Image.Stretch
                                opacity: acceptNameButton.enabled? 1.0 : 0.5
                            }
                        }

                        Button {
                            id: rejectButton
                            text: "Отмена"
                            font.pixelSize: 16
                            leftPadding: rejectButton.pressed ? 8 : 4
                            topPadding: rejectButton.pressed ? 8 : 4

                            implicitWidth: 140
                            implicitHeight: implicitWidth / 3.4

                            onClicked: {
                                networkPopup.close()
                            }

                            background: Image {
                                source: rejectButton.pressed? "images/ButtonBG_pressed.png" :
                                        rejectButton.hovered? "images/ButtonBG_hover.png" :
                                                            "images/ButtonBG_not_pressed.png"
                                fillMode: Image.Stretch
                            }
                        }
                    }
                }
            }

            // Страница 1: обнаруженные игроки
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

                        model: networkManager.playersModel

                        delegate: Rectangle {
                            id: playerDelegate

                            required property string playerName
                            required property int index

                            width: playersList.width
                            height: 44
                            radius: 6

                            color: ListView.isCurrentItem
                                   ? "#90CAF9"
                                   : "#C1C9CC"

                            border.width:
                                ListView.isCurrentItem ? 2 : 1

                            border.color:
                                ListView.isCurrentItem
                                ? "#1976D2"
                                : "#C1C9CC"

                            Text {
                                anchors.centerIn: parent

                                text: playerDelegate.playerName
                                color: "#000000"
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    playersList.currentIndex =
                                        playerDelegate.index

                                    console.log(
                                        "<NetworkPopup> выбран игрок:",
                                        playerDelegate.playerName,
                                        "index:",
                                        playerDelegate.index
                                    )
                                }
                            }
                        }

                        Text {
                            anchors.centerIn: parent

                            visible: playersList.count === 0

                            text: "Поиск доступных игроков..."
                            color: "#C1C9CC"
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
                                const selectedIndex =
                                    playersList.currentIndex

                                if (selectedIndex < 0)
                                    return

                                console.log(
                                    "<NetworkPopup> Подключение к игроку. Index:",
                                    selectedIndex
                                )

                                statusPopup.open()

                                networkManager.connectToPlayer(
                                    selectedIndex
                                )
                            }
                        }

                        Button {
                            text: "Назад"

                            Layout.preferredWidth: 110

                            onClicked: {
                                connectionRequestPopup.close()
                                statusPopup.close()

                                networkManager.stopDiscovery()

                                networkPopup.showPlayers = false

                                playersList.currentIndex = -1

                                nameInput.forceActiveFocus()
                            }
                        }
                    }
                }
            }
        }
    }

    Connections {
        target: networkManager

        function onConnectionRequestReceived(playerName) {
            /*
                Запрос показывается только если:
                1) NetworkPopup открыт;
                2) имя введено;
                3) отображается список найденных игроков;
                4) нет исходящего запроса подключения.
            */
            if (!networkPopup.visible)
                return

            if (!networkPopup.showPlayers)
                return

            if (networkManager.playerName.trim().length === 0)
                return

            if (statusPopup.visible)
                return

            connectionRequestPopup.requestedPlayerName =
                playerName

            connectionRequestPopup.open()
        }

        function onConnectedChanged() {
            if (!networkManager.connected)
                return

            connectionRequestPopup.close()
            statusPopup.close()

            networkPopup.close()
            stackView.push("PlacementScreen.qml")
        }

        function onNetworkError(message) {
            statusPopup.close()

            networkPopup.errorText = message

            if (networkPopup.showPlayers) {
                console.log(
                    "<NetworkPopup> Ошибка сети:",
                    message
                )
            }
        }

        function onConnectionRejected(reason) {
            statusPopup.close()

            networkPopup.errorText = reason

            console.log(
                "<NetworkPopup> Подключение отклонено:",
                reason
            )
        }
    }
}
