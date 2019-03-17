import QtQuick 2.0
import Sailfish.Silica 1.0

import "../settings.js" as Settings
import "../gameoflife.js" as Game

Page {
    id: page


    // The effective value will be restricted by ApplicationWindow.allowedOrientations
    allowedOrientations: Orientation.Portrait

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable {
        anchors.fill: parent

        // PullDownMenu and PushUpMenu must be declared in SilicaFlickable, SilicaListView or SilicaGridView



        Grid  {
            id: gridButtons
            width: parent.width
            height: butClear.height * 2
            columns: 3
            spacing: 2
            z: canvas.z+1

            Button {
                id: butClear
                width:  (parent.width/gridButtons.columns) - gridButtons.spacing
                text: qsTr("Clear")
                onClicked:  {
                    if(Game.Inited) {
                        Game.clear()
                        canvas.requestPaint()
                    }
                }
            }
            Button {
                width: (parent.width/gridButtons.columns) - gridButtons.spacing
                text: qsTr("Random init")
                onClicked:  {
                    if(Game.Inited) {
                        Game.clear()
                        Game.initRandom()
                        canvas.requestPaint()
                    }
                }
            }
            Button {
                width:  (parent.width/gridButtons.columns) - gridButtons.spacing
                text: qsTr("Start")
                onClicked: {
                    if(Game.Inited)
                        timer.start()
                }
            }
            Button {
                id: butStop
                width:  (parent.width/gridButtons.columns) - gridButtons.spacing
                text: qsTr("Stop and Edit")
                onClicked: {
                    if(Game.Inited) {
                        timer.stop();
                        canvas.requestPaint();
                    }
                }
            }
            Button {
                id: butSpeedDown
                width:  (parent.width/gridButtons.columns) - gridButtons.spacing
                text: qsTr("Speed -")
                onClicked: {
                    if(Game.Inited) {
                        timer.interval *=2;
                        if(timer.interval > 4000)
                            timer.interval = 4000;
                    }
                }
            }
            Button {
                id: butSpeedUp
                width:  (parent.width/gridButtons.columns) - gridButtons.spacing
                text: qsTr("Speed +")
                onClicked: {
                    if(Game.Inited) {
                        timer.interval /=2;
                        if(timer.interval < 10)
                            timer.interval = 10;

                    }
                }
            }
        }




        Canvas {
            id:canvas
            y:  gridButtons.height + gridButtons.spacing
            height: parent.height - gridButtons.height - gridButtons.spacing
            width: parent.width

            onPaint:  {
                var ctx = getContext("2d");

                if(timer.running)
                    ctx.fillStyle = Qt.rgba(0,0,0,1);
                else
                    ctx.fillStyle = Qt.rgba(0.3,0.3,0.3,1);

                ctx.fillRect(0,0, width, height);

                if(Game.Inited) {
                    Game.gameDraw(ctx, width, height)
                }
            }
            MouseArea {
                id:area
                anchors.fill: parent
                onClicked: {

                    var ci = Math.floor(mouseX / Game.blockSize);
                    var cj = Math.floor(mouseY / Game.blockSize);

                    console.log(ci  + " " + cj);


                    if (ci >= 0 && ci < Game.maxColumn && cj >= 0 && cj < Game.maxRow) {
                        Game.changeCell(ci, cj);
                    }
                    canvas.requestPaint()
                }
            }

            Component.onCompleted: {
                canvas.requestPaint()
                Game.reInitArea( width, height )
            }


        }

        Timer {
            id:timer
            repeat: true
            running: false
            interval:  200
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
