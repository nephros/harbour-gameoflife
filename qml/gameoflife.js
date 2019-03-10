/* This script file handles the game logic */
.pragma library
.import "./settings.js" as Settings

var maxColumn = Settings.FIELDSIZE;
var maxRow = Settings.FIELDSIZE;
var maxIndex = maxColumn*maxRow;

function Cell(isLive_) {
    this.isLive = isLive_;
    this.mustdie = false;
    this.mustbirth = false;
}

var cells = [];

function index(column, row)
{
    return column + row * maxColumn;
}

function init() {
    cells = [];
    for (var i = 0; i < maxIndex; i++) {
        cells.push(new Cell((Math.random() >= 0.8) ? true : false));
    }
}

function gameDraw(ctx, width, height) {

    ctx.fillStyle = Qt.rgba(0,0,0,1);
    ctx.fillRect(0,0, width, height);
    ctx.fillStyle = Qt.rgba(1,1,1,1);

    if(cells.length == 0)
        return;
    var i, j;

    for ( i = 0; i < maxColumn; i++) {
        for ( j = 0; j < maxRow; j++) {
            var cell = new Cell();

            if ( cells[index(i,j)].isLive === true ) {
                var rectX = (i * Settings.blockSize);
                var rectY = (j * Settings.blockSize);
                ctx.fillRect(rectX,rectY, Settings.blockSize, Settings.blockSize);
            }
        }
    }


}

function gameUpdate() {
    var i, j;

    for ( i = 0; i < maxColumn; i++) {
        for ( j = 0; j < maxRow; j++) {
            cells[index(i,j)].mustdie = false;
            cells[index(i,j)].mustbirth = false;
        }
    }

    for ( i = 1; i < maxColumn-1; i++) {
        for ( j = 1; j < maxRow-1; j++) {
            var counter = 0;
            for (var di = -1; di <= 1; di++) {
                for (var dj = -1; dj <= 1; dj++) {
                    if (di == 0 && dj == 0)
                        continue;

                    if (cells[index(i + di, j + dj)].isLive !== undefined && cells[index(i + di, j + dj)].isLive === true) {
                        counter++;
                    }
                }
            }

            if (counter == 3)
                cells[index(i,j)].mustbirth = true;
            else if (counter > 3 || counter < 2)
                cells[index(i,j)].mustdie = true;

        }
    }

    for ( i = 0; i < maxColumn; i++) {
        for ( j = 0; j < maxRow; j++) {
            if (cells[index(i,j)].mustdie && cells[index(i,j)].isLive ) {
                cells[index(i,j)].isLive = false;
                cells[index(i,j)].mustdie = false;

            }
            if (cells[index(i,j)].mustbirth && !cells[index(i,j)].isLive) {
                cells[index(i,j)].isLive = true;
                cells[index(i,j)].mustbirth = false;
            }
        }
    }
}
