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
                text: qsTr("New game")
                onClicked:  {
                    Game.clear()
                    canvas.requestPaint()
                }
            }
            MenuItem {
                text: qsTr("Random init")
                onClicked:  {
                    Game.initRandom()
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
            onPaint:  {
                var ctx = getContext("2d");
                if(timer.running)
                    ctx.fillStyle = Qt.rgba(0,0,0,1);
                else
                    ctx.fillStyle = Qt.rgba(0.3,0.3,0.3,1);

                ctx.fillRect(0,0, width, height);
                Game.gameDraw(ctx, width, height)
            }
            MouseArea {
                id:area
                anchors.fill: parent
                onClicked: {

                    var ci = Math.round(mouseX / Settings.blockSize);
                    var cj = Math.round(mouseY / Settings.blockSize);

                    console.log(ci  + " " + cj);


                    if (ci >= 0 && ci < Game.maxColumn && cj >= 0 && cj < Game.maxRow) {
                        Game.changeCell(ci, cj);
                    }
                    canvas.requestPaint()
                }
            }

            Component.onCompleted: {
                Game.clear()
                canvas.requestPaint()
            }
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

        BusyIndicator {
           size: BusyIndicatorSize.ExtraSmall
           anchors.bottom:   parent.bottom
           anchors.bottomMargin: Theme.paddingMedium
           x: Theme.paddingMedium
           running:  timer.running
        }




    }
}
