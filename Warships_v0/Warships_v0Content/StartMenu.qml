import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Warships 1.0
import QtQuick.Studio.DesignEffects

Rectangle {
    id: startMenu
    anchors.fill: parent
    color: "#f0f4f8"

    readonly property real refWidth: Screen.width
    readonly property real refHeight: Screen.height
    readonly property real ratio:
        Math.min(1, width / refWidth, height / refHeight)

    GridLayout {
        id: grid
        z: 2
        columns: 2
        anchors.centerIn: parent
        columnSpacing: 12 * startMenu.ratio
        rowSpacing: 12 * startMenu.ratio

        Repeater {
            model: [
                "Одиночная игра",
                "Сетевая игра",
                "Магазин",
                "Выйти"
            ]

            Button {
                id: menuButton
                text: modelData
                font.letterSpacing: 0.3
                font.styleName: "Bold"
                font.weight: Font.ExtraBold
                palette.buttonText: "#C1C9CC"
                font.family: "Verdana"
                font.pointSize: 13.5 * startMenu.ratio * 1.55
                font.bold: true
                Layout.preferredWidth:
                    startMenu.refWidth * 0.25 * startMenu.ratio
                Layout.preferredHeight:
                    startMenu.refHeight * 0.12 * startMenu.ratio

                background: Image {
                    source: "images/ButtonBG.png"
                    fillMode: Image.Stretch
                }

                TextMetrics {
                    id: textMetrics
                    text: modelData
                    font: menuButton.font
                }


                onClicked: {
                    switch (index) {
                    case 0:
                        console.log("<Главное меню> Выбрана одиночная игра")
                        gameController.start_PvAI()
                        stackView.push("PlacementScreen.qml")
                        break

                    case 1:
                        console.log("<Главное меню> Выбрана сетевая игра")
                        gameController.start_Local()
                        root.networkPopup.open()
                        break

                    case 2:
                        console.log("<Главное меню> Выбран магазин")
                        // открытие магазина
                        break

                    case 3:
                        console.log("<Главное меню> Выход из игры")
                        Qt.quit()
                        break
                    }
                }
            }
        }
    }

    Image {
        id: mainmenu_bg
        visible: true
        anchors.fill: parent
        source: "images/MainMenu.png"
        z: 1
        fillMode: Image.PreserveAspectCrop
    }

    Text {
        id: copyright_text
        y: 1019
        color: "#C1C9CC"
        text: qsTr("2026")
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 0
        anchors.bottomMargin: 0
        font.pixelSize: startMenu.ratio * 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignBottom
        font.styleName: "Bold"
        font.family: "Verdana"
        z: 100
    }
}
