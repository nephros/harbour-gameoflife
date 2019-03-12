import QtQuick 2.0
import Sailfish.Silica 1.0

import "../settings.js" as Settings
import "../gameoflife.js" as Game

Page {
    id: page


    Component.onCompleted: {
        Settings.blockSize = Screen.width / (Settings.FIELDSIZE-1)

    }

    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.All

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView


        Grid  {
            id: gridButtons
            width: parent.width
            columns: 2
            spacing: 2
            z: canvas.z+1
            Button {
                width: parent.width/2 -1

                text: qsTr("Clear")
                onClicked:  {
                    Game.clear()
                    canvas.requestPaint()
                }
            }
            Button {
                width: parent.width/2 -1
                text: qsTr("Random init")
                onClicked:  {
                    Game.initRandom()
                    canvas.requestPaint()
                }
            }
            Button {
                width: parent.width/2 -1
                text: qsTr("Start")
                onClicked: timer.start()
            }
            Button {
                width: parent.width/2 -1
                text: qsTr("Stop and Edit")
                onClicked: {
                    timer.stop();
                    canvas.requestPaint();
                }
            }

        }


        Canvas {
            id:canvas
            anchors.top: gridButtons.bottom
            anchors.bottom: parent.bottom

            width: parent.width
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

                    var ci = Math.floor(mouseX / Settings.blockSize) + 1;
                    var cj = Math.floor(mouseY / Settings.blockSize) + 1;

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
            size: BusyIndicatorSize.Medium
            anchors.bottom:   parent.bottom
            anchors.bottomMargin: Theme.paddingMedium
            x: Theme.paddingMedium
            running:  timer.running
        }




    }
}
