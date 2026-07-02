import QtQuick
import QtQuick.Controls
import Warships_v0

Window {
    id: root
    width: Constants.width
    height: Constants.height

    visible: true

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: StartMenu {}
    }

    // TODO: delete toolbar
    ToolBar {
        id: toolBar
        anchors.right: parent.right
        anchors.left: parent.left
        contentHeight: 50

        ToolButton {
            id: toolButton
            text: stackView.depth > 1 ? "\u25C0" : "\u2630"
            font:  Constants.largeFont
            onClicked: {
                if (stackView.depth > 1) {
                    stackView.pop()
                } else {
                    drawer.open()
                }
            }
        }
    }

    Drawer {
        id: drawer
        width: root.width * 0.33
        height: root.height

        Column {
            anchors.fill: parent

            ItemDelegate {
                text: qsTr("Page 1")
                width: parent.width
                onClicked: {
                    stackView.push("StartMenu.ui.qml")
                    drawer.close()
                }
            }
            ItemDelegate {
                text: qsTr("Page 2")
                width: parent.width
                onClicked: {
                    stackView.push("GameScreen.ui.qml")
                    drawer.close()
                }
            }
        }
    }
}


