import QtQuick
import QtQuick.Controls
import Warships_v0

Window {
    id: root
    width: Constants.width
    height: Constants.height

    visible: true

    property alias networkPopup: networkPopup

    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: StartMenu {}
    }

    NetworkPopup {
        id: networkPopup
    }

    Connections {
        target: networkManager

        function onOpponentDisconnected() {
            console.log("<App> Соперник отключился")

            // Сброс игровых состояний
            gameController.clearController();

            while (stackView.depth > 1) {
                stackView.pop()
            }

            networkPopup.open()
        }
    }
}
