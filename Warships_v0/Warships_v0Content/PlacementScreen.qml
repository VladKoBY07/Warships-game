import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts

Item {
    id: placementScreen
    anchors.fill: parent // размер под родителя, как у главного меню

    //свойство для доступа к stackView
    property StackView stackView: StackView.view

    // Текст верхней плашки (используется и на экране расстановки, и в анимации старта игры)
    property string overlayText: "Подготовка к бою"

    // Абсолютные координаты статичного дока (в системе координат gameContent)
    readonly property real dockAbsX: dock.x
    readonly property real dockAbsY: dock.y


    // Раскладка кораблей в доке: длина + смещение (ox, oy) внутри дока.
    ListModel {
        id: shipDockLayout
        ListElement { len: 4; ox: 15;  oy: 45  }
        ListElement { len: 3; ox: 15;  oy: 100 }
        ListElement { len: 3; ox: 15;  oy: 155 }
        ListElement { len: 2; ox: 15;  oy: 210 }
        ListElement { len: 2; ox: 110; oy: 210 }
        ListElement { len: 2; ox: 15;  oy: 265 }
        ListElement { len: 1; ox: 15;  oy: 320 }
        ListElement { len: 1; ox: 65;  oy: 320 }
        ListElement { len: 1; ox: 115; oy: 320 }
        ListElement { len: 1; ox: 165; oy: 320 }
    }

    // ===== Весь игровой контент — можно блюрить и блокировать целиком =====
    Item {
        id: gameContent
        anchors.fill: parent
        enabled: false

        Rectangle {
            id: board
            anchors.centerIn: parent
            width: 10 * 40
            height: 10 * 40
            color: "#FFFFFF"
            border.color: "#BDBDBD"
            border.width: 1

            property int cols: 10
            property int rows: 10
            property int cellSize: 40

            Repeater {
                model: board.rows
                Rectangle {
                    width: board.width
                    height: board.cellSize
                    y: index * board.cellSize
                    color: "transparent"
                    border.color: "#EEEEEE"
                    border.width: 1
                }
            }

            Repeater {
                model: board.cols
                Rectangle {
                    width: board.cellSize
                    height: board.height
                    x: index * board.cellSize
                    color: "transparent"
                    border.color: "#EEEEEE"
                    border.width: 1
                }
            }
        }

        Rectangle {
            id: dock
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.top: board.top
            width: 230
            height: 380
            color: "#EEEEEE"
            border.color: "#BDBDBD"
            border.width: 1
            radius: 8

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: parent.top
                anchors.topMargin: 8
                text: "Док"
                font.bold: true
                color: "#616161"
            }
        }

        // ===== Корабли — дети gameContent, свободно перетаскиваются по всему экрану =====
        Repeater {
            id: shipRepeater
            model: shipDockLayout

            ShipItem {
                id: shipDelegate
                shipLength: len
                cellSize: board.cellSize
                boardX: board.x
                boardY: board.y
                boardCols: board.cols
                boardRows: board.rows

                dockX: placementScreen.dockAbsX
                dockY: placementScreen.dockAbsY
                dockWidth: dock.width
                dockHeight: dock.height

                x: placementScreen.dockAbsX + ox
                y: placementScreen.dockAbsY + oy

                property bool suppressMoveAnim: false
                Behavior on x { enabled: !suppressMoveAnim; NumberAnimation { duration: 120 } }
                Behavior on y { enabled: !suppressMoveAnim; NumberAnimation { duration: 120 } }
            }
        }

        Button {
            id: readyButton
            text: "Готово"
            anchors.top: board.bottom
            anchors.topMargin: 20
            anchors.horizontalCenter: board.horizontalCenter
        }

        // Логика "Готово": проверяем, что все корабли расставлены (placed == true),
        // и если да — запускаем переход дальше.

        //Todo: Нужно переделать - вызвать какую-то функцию через логику доски, и как-то сконектить с .ui.qml
        //Либо оставить, на ваше усмотрение

        Connections {
            target: readyButton
            function onClicked() {
                var allPlaced = true
                for (var i = 0; i < shipRepeater.count; ++i) {
                    if (!shipRepeater.itemAt(i).placed) {
                        allPlaced = false
                        break
                    }
                }

                if (allPlaced) {
                    waitingPopup.visible = true
                    // Переход на экран боя (GameScreen_ui.qml)
                    placementScreen.stackView.push(Qt.resolvedUrl("GameScreen.qml"))
                    waitingPopup.visible = false
                } else {
                    warningToastAnimation.restart()
                }
            }
        }

        Button {
            id: clearButton
            text: "Очистить"
            anchors.top: readyButton.bottom
            anchors.topMargin: 12
            anchors.horizontalCenter: board.horizontalCenter
        }

        Connections {
            target: clearButton
            function onClicked() {
                gameBoard.clearBoards()

                for (var i = 0; i < shipRepeater.count; ++i) {
                    var shipItem = shipRepeater.itemAt(i)
                    var homeSpot = shipDockLayout.get(i)

                    shipItem.suppressMoveAnim = true

                    shipItem.placed = false
                    shipItem.gridX = -1
                    shipItem.gridY = -1
                    shipItem.horizontal = true
                    shipItem.width = shipItem.shipLength * shipItem.cellSize
                    shipItem.height = shipItem.cellSize
                    shipItem.x = placementScreen.dockAbsX + homeSpot.ox
                    shipItem.y = placementScreen.dockAbsY + homeSpot.oy

                    shipItem.suppressMoveAnim = false
                }
            }
        }

    }

    Popup {
        id: waitingPopup
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

    // ===== Блюр поверх gameContent =====
    MultiEffect {
        id: blurEffect
        anchors.fill: gameContent
        source: gameContent
        blurEnabled: true
        blurMax: 32
        autoPaddingEnabled: true

        property real amount: 0.0
        blur: amount
    }

    // Затемнение фона
    Rectangle {
        id: dimOverlay
        anchors.fill: parent
        color: "#000000"
        opacity: 0.0
    }

    // ===== Уведомление "не все корабли расставлены" =====
    Rectangle {
        id: warningToast
        z: 1000
        width: 460
        height: 100
        radius: 10

        color: "#FCE4EC"
        border.color: "#880E4F"
        border.width: 2
        anchors.horizontalCenter: parent.horizontalCenter

        y: parent.height

        Text {
            anchors.centerIn: parent
            text: "Не все корабли расставлены!"
            font.pixelSize: 28
            font.bold: true
            color: "#880E4F"
        }
    }

    // Анимация выдвижения плажки

    SequentialAnimation {
        id: warningToastAnimation

        NumberAnimation {
            target: warningToast;
            property: "y";
            from: warningToast.parent.height;
            to: warningToast.parent.height - warningToast.height - 40;
            duration: 300;
            easing.type: Easing.OutQuad
        }

        PauseAnimation { duration: 1400 }

        NumberAnimation {
            target: warningToast;
            property: "y";
            from: warningToast.parent.height - warningToast.height - 40;
            to: warningToast.parent.height;
            duration: 300;
            easing.type: Easing.InQuad
        }
    }

    // ===== Текстовая плашка — используется и при входе на экран
    Rectangle {
        id: introBox
        width: 380
        height: 90
        radius: 10
        color: "#F5F5F5"
        border.color: "#BDBDBD"
        border.width: 1
        opacity: 0.0
        anchors.horizontalCenter: parent.horizontalCenter
        y: placementScreen.height / 2 - height / 2 // стартовая позиция — по центру экрана

        Text {
            anchors.centerIn: parent
            text: "Подготовка к бою"
            font.pixelSize: 30
            font.bold: true
            color: "#000000"
        }
    }

    // ===== Анимация появления экрана (при входе на страницу) =====
    SequentialAnimation {
        id: introAnimation
        running: true

        ParallelAnimation {
            NumberAnimation { target: blurEffect; property: "amount"; from: 0.0; to: 1.0; duration: 300; easing.type: Easing.OutQuad }
            NumberAnimation { target: dimOverlay; property: "opacity"; from: 0.0; to: 0.35; duration: 300 }
        }

        NumberAnimation { target: introBox; property: "opacity"; from: 0.0; to: 1.0; duration: 250 }

        PauseAnimation { duration: 700 }

        NumberAnimation {
            target: introBox
            property: "y"
            to: 40
            duration: 500
            easing.type: Easing.InOutQuad
        }

        ParallelAnimation {
            NumberAnimation { target: blurEffect; property: "amount"; from: 1.0; to: 0.0; duration: 300; easing.type: Easing.InQuad }
            NumberAnimation { target: dimOverlay; property: "opacity"; from: 0.35; to: 0.0; duration: 300 }
        }

        ScriptAction { script: gameContent.enabled = true }
        ScriptAction { script: introBox.anchors.top = placementScreen.top }
        ScriptAction { script: introBox.anchors.topMargin = 40 }
    }
}
