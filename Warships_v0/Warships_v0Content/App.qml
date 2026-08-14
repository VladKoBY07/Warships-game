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
}


