import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Warships 1.0
import QtQuick.Studio.DesignEffects
import QtMultimedia

Rectangle {
    id: startMenu
    anchors.fill: parent
    color: "#f0f4f8"

    readonly property real refWidth: 1920
    readonly property real refHeight: 1080
    readonly property real ratio: Math.min(1.0, Math.min(width / refWidth, height / refHeight))

    GridLayout {
        id: grid
        z: 2
        columns: startMenu.width < 980 ? 1 : 2
        anchors.centerIn: parent
        columnSpacing: 5 * startMenu.ratio
        rowSpacing: 4 * startMenu.ratio

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
                font.pointSize: menuButton.height * 0.17
                font.bold: true
                Layout.preferredWidth: Math.max(400, 420 * startMenu.ratio)
                Layout.preferredHeight: Math.max(110, 110 * startMenu.ratio)

                leftPadding: menuButton.pressed ? 8 : 2
                topPadding: menuButton.pressed ? 8 : 2

                background: Image {
                    source: menuButton.pressed? "images/ButtonBG_pressed.png" :
                            menuButton.hovered? "images/ButtonBG_hover.png" :
                                                "images/ButtonBG_not_pressed.png"
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

    Video{
        id: menuBG
        anchors.fill: parent
        source: "images/MenuAnimated.mp4"
        playbackRate: 1
        fillMode: VideoOutput.PreserveAspectCrop
        loops: MediaPlayer.Infinite

        Image {
            anchors.fill: parent
            source: "images/MainMenu.png"
            fillMode: Image.PreserveAspectCrop
            visible: menuBG.playbackState !== MediaPlayer.PlayingState
        }

        Component.onCompleted: play()
    }

    Text {
        id: copyright_text
        y: 1019
        color: "#C1C9CC"
        text: qsTr("2026")
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: 50
        anchors.bottomMargin: 10
        font.pixelSize: startMenu.ratio * 20
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignBottom
        font.styleName: "Bold"
        font.family: "Verdana"
        z: 100
    }
}
