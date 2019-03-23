import QtQuick 2.0
import Sailfish.Silica 1.0

import "../settings.js" as Settings
import "../gameoflife.js" as Game

Page {
    id: page


    function sv() {
        var text = "1111111111111";
        var filename = "textfile";
        var blob = new Blob([text], {type: "text/plain;charset=utf-8"});
        saveAs(blob, filename+".txt");
    }

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
            columns: 4
            spacing: 2
            z: canvas.z+1

            Column {
                width: (parent.width/gridButtons.columns) - gridButtons.spacing
                height: butClear.height * 2
                spacing: 2
                Button {
                    id: butClear
                    width:  parent.width
                    text: qsTr("Clear")
                    onClicked:  {
                        if(Game.Inited) {
                            Game.clear()
                            canvas.requestPaint()
                        }
                    }
                }
                Button {
                    width:  parent.width
                    text: qsTr("Random")
                    onClicked:  {
                        if(Game.Inited) {
                            Game.clear()
                            Game.initRandom()
                            canvas.requestPaint()
                        }
                    }
                }
            }
            Column {
                width: (parent.width/gridButtons.columns) - gridButtons.spacing
                height: butClear.height * 2
                spacing: 2
                Button {
                    width:   parent.width
                    text: qsTr("Start")
                    onClicked: {
                        if(Game.Inited)
                            timer.start()
                    }
                }
                Button {
                    id: butStop
                    width:  parent.width
                    text: qsTr("Stop/Edit")
                    onClicked: {
                        if(Game.Inited) {
                            timer.stop();
                            canvas.requestPaint();
                        }
                    }
                }
            }

            Column {
                width: (parent.width/gridButtons.columns) - gridButtons.spacing
                height: butClear.height * 2
                spacing: 2
                Button {
                    id: butSpeedUp
                    width:  parent.width
                    text: qsTr("Speed +")
                    onClicked: {
                        if(Game.Inited) {
                            timer.interval /=2;
                            if(timer.interval < 10)
                                timer.interval = 10;

                        }
                    }
                }
                Button {
                    id: butSpeedDown
                    width:   parent.width
                    text: qsTr("Speed -")
                    onClicked: {
                        if(Game.Inited) {
                            timer.interval *=2;
                            if(timer.interval > 4000)
                                timer.interval = 4000;
                        }
                    }
                }

            }

            Column {
                width: (parent.width/gridButtons.columns) - gridButtons.spacing
                height: butClear.height * 2
                spacing: 2
                Button {
                    id: butAreaUp
                    width:   parent.width
                    text: qsTr("Area +")
                    onClicked: {
                        Game.blockSize /= 1.5
                        if(Game.blockSize < 10)
                            Game.blockSize = 10;

                        Game.reInitArea( canvas.width, canvas.height )
                        canvas.requestPaint()
                    }
                }
                Button {
                    id: butAreaDown
                    width:  parent.width
                    text: qsTr("Area -")
                    onClicked: {
                        Game.blockSize *= 1.5
                        if(Game.blockSize > 50)
                            Game.blockSize = 50;

                        Game.reInitArea( canvas.width, canvas.height )
                        canvas.requestPaint()
                    }
                }
            }

        }




        Canvas {
            id:canvas
            y:  gridButtons.height + gridButtons.spacing * 2
            height: parent.height - gridButtons.height - gridButtons.spacing
            width: parent.width

            onPaint:  {
                var ctx = getContext("2d");
                ctx.reset();

                if(timer.running)
                    ctx.fillStyle = Qt.rgba(0,0,0,0.5);
                else
                    ctx.fillStyle = Qt.rgba(0.5,0.5,0.5,1);

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
                Game.createCells()
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
