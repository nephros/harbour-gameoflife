import QtQuick 2.0
import Sailfish.Silica 1.0

import "../settings.js" as Settings
import "../gameoflife.js" as Game

Page {
    id: page

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView
        PullDownMenu {
            MenuItem {
                text: qsTr("Reset game")
                onClicked:  {
                    Game.init()
                    canvas.requestPaint()
                }
            }
            MenuItem {
                text: qsTr("Start")
                onClicked: timer.start()
            }
            MenuItem {
                text: qsTr("Stop")
                onClicked: timer.stop()
            }

        }

        Canvas {
            id:canvas
            anchors.fill: parent
            onPaint: Game.gameDraw(getContext("2d"), width, height)
        }

        Timer {
            id:timer
            repeat: true
            running: false
            interval: 250
            onTriggered: {
                Game.gameUpdate()
                canvas.requestPaint()
            }
        }

    }
}
