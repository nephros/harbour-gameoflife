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

    allowedOrientations: Orientation.All

    PullDownMenu { id: menu
        flickable: flick
        MenuItem { id: butClear
            text: qsTr("Clear")
            onClicked:  {
                if(Game.Inited) {
                    Game.clear()
                    canvas.requestPaint()
                }
            }
        }
        MenuItem {
            text: qsTr("Random")
            onClicked:  {
                if(Game.Inited) {
                    Game.clear()
                    Game.initRandom()
                    canvas.requestPaint()
                }
            }
        }
        MenuItem {
            text: timer.running ? qsTr("Stop/Edit") : qsTr("Start")
            onClicked: {
                if(Game.Inited) {
                    timer.start()
                } else {
                    timer.stop();
                    canvas.requestPaint();
                }
            }
        }
    }

    // To enable PullDownMenu, place our content in a SilicaFlickable
    SilicaFlickable { id: flick
        anchors.fill: parent
        anchors.centerIn: parent

        Row  { id: gridButtons
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            height: butSpeedUp.height
            spacing: page.isPortrait ? Theme.paddingLarge : Theme.itemSizeMedium
            z: canvas.z+1
            IconButton { id: butSpeedDown
                icon.source: "image://theme/icon-m-enter-accept"
                rotation: 180
                onClicked: {
                    if(Game.Inited) {
                        timer.interval *=2;
                        if(timer.interval > 4000)
                            timer.interval = 4000;
                    }
                }
            }
            IconButton { id: butSpeedUp
                icon.source: "image://theme/icon-m-enter-accept"
                onClicked: {
                    if(Game.Inited) {
                        timer.interval /=2;
                        if(timer.interval < 10)
                            timer.interval = 10;

                    }
                }
            }
            IconButton { id: butAreaDown
                icon.source: "image://theme/icon-m-add-to-grid"
                onClicked: {
                    Game.blockSize *= 1.5
                    if(Game.blockSize > 50)
                        Game.blockSize = 50;

                    Game.reInitArea( canvas.width, canvas.height )
                    canvas.requestPaint()
                }
            }
            IconButton { id: butAreaUp
                icon.source: "image://theme/icon-m-add-to-grid"
                icon.width: Theme.iconSizeSmall
                icon.height: Theme.iconSizeSmall
                onClicked: {
                    Game.blockSize /= 1.5
                    if(Game.blockSize < 10)
                        Game.blockSize = 10;

                    Game.reInitArea( canvas.width, canvas.height )
                    canvas.requestPaint()
                }
            }

        }

        Canvas {
            id: canvas
            anchors.top: gridButtons.bottom
            anchors.bottom: statusLine.top
            anchors.horizontalCenter: parent.horizontalCenter
            //height: parent.height - gridButtons.height - statusLine.height
            width: parent.width

            // portrait/landscape change:
            onWidthChanged: timer.running ? Game.reInitArea( width, height ) : true

            renderStrategy: Canvas.Threaded
            // causes stutter/speedup issues
            //renderTarget: Canvas.FramebufferObject

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
            MouseArea { id: area
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
                // set up
                Game.blockSize       = Theme.paddingLarge
                Game.blockColorFill  = Theme.rgba(Theme.primaryColor,1);
                Game.blockColorDead  = Qt.darker(Theme.presenceColor(Theme.PresenceBusy))
                Game.blockColorAlive = Theme.secondaryHighlightColor

                canvas.requestPaint()
                Game.createCells()
                Game.reInitArea( width, height )
            }
        }

        Item { id: statusLine
            width: parent.width - Theme.horizontalPageMargin
            height: grid1.height
            anchors.bottom: parent.bottom
            property int gen
            property int pop
            property int deaths
            property int births
            Grid { id: grid1
                rows: 2; columns: 2
                anchors.left: parent.left
                Label {text: "generation: "} Label {text: statusLine.gen}
                Label {text: "population: "} Label {text: statusLine.pop}
            }
            Grid {
                rows: 2; columns: 2
                anchors.right: parent.right
                Label {text: "births: "} Label {text: statusLine.births}
                Label {text: "deaths: "} Label {text: statusLine.deaths}
            }
        }

        Timer { id: timer
            repeat: true
            running: false
            interval:  200
            onTriggered: {
                Game.gameUpdate();
                if (Game.population === 0)
                    stop();
                canvas.requestPaint();
                statusLine.gen = Game.generationsCounter;
                statusLine.pop = Game.population;
                statusLine.deaths = Game.deathsCounter;
                statusLine.births = Game.birthsCounter;
            }
        }


    }
}
