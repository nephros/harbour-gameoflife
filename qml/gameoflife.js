/* This script file handles the game logic */
.pragma library
.import "./settings.js" as Settings


var maxColumn   = 1000;
var maxRow      = 1000;
var maxIndex    = 1000000;
var blockSize   = 40
var Inited = false
var cells = [];


function reInitArea(areaWidth, areaHeight) {
    maxColumn = Math.floor(areaWidth / blockSize);
    maxRow =   Math.floor(areaHeight / blockSize);
    maxIndex = maxColumn*maxRow;

    cells = [];
    for (var i = 0; i < maxIndex; i++) {
        cells.push(new Cell(false));
    }

    Inited = true
}

function Cell(isLive_) {
    this.isLive = isLive_;
    this.mustdie = false;
    this.mustbirth = false;
}


function index(column, row)
{
    return column + row * maxColumn;
}

function clear() {
    for (var i = 0; i < maxIndex; i++) {
        if(cells[i] instanceof Cell) {
            cells[i].isLive = false
            cells[i].mustdie = false;
            cells[i].mustbirth = false;
        }
    }
}
function initRandom() {
    for (var i = 0; i < maxIndex; i++) {
        cells[i].mustdie = false;
        cells[i].mustbirth = false;
        cells[i].isLive = (Math.random() >= 0.8) ? true : false;
    }
}

function leftOf(i) {
    var n = i-1;
    if(n < 0)
        return maxColumn-1;

    return n;
}

function rightOf(i) {
    var n = i+1;
    if(n >= maxColumn)
        return 0;
    return n;
}

function upOf(j) {
    var n = j-1;
    if(n < 0)
        return maxRow-1;

    return n;
}

function downOf(j) {
    var n = j+1;
    if(n >= maxRow)
        return 0;
    return n;
}


function gameDraw(ctx, width, height) {




    if(!Inited)
        return;
    if(cells.length == 0)
        return;

    var i, j;
    for ( i = 0; i < maxColumn; i++) {
        for ( j = 0; j < maxRow; j++) {
            var rectX = (i * blockSize);
            var rectY = (j * blockSize);

            // ctx.fillStyle = Qt.rgba(0,0,0,1);

            if(cells[index(i,j)] instanceof Cell) {
                if ( cells[index(i,j)].isLive === true ) {
                    ctx.fillStyle = cells[index(i,j)].mustdie ? Qt.rgba(1,0.5,0.5,1) : Qt.rgba(1,1,1,1) ;
                    ctx.fillRect(rectX ,rectY, blockSize, blockSize);

                }
                else if ( cells[index(i,j)].mustbirth === true ) {
                    ctx.fillStyle = Qt.rgba(0,0.5,0,1);
                    ctx.fillRect(rectX +  blockSize*0.25 ,rectY  +  blockSize*0.25, blockSize*0.5, blockSize*0.5);
                }


            }
        }
    }
}

function changeCell(n, m) {

    if(!Inited)
        return;

    if(cells.length == 0)
        return;

    cells[index(n,m)].isLive =  !cells[index(n,m)].isLive;

    if(!!cells[index(n,m)].isLive) {
        cells[index(n,m)].mustdie = false
    }


}

function gameUpdate() {
    if(!Inited)
        return;

    var i, j;



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


    for (  i = 0; i < maxIndex; i++) {
        if(cells[i] instanceof Cell) {
            cells[i].mustdie = false;
            cells[i].mustbirth = false;
        }
    }

    for ( i =0; i < maxColumn; i++) {
        for ( j = 0; j < maxRow; j++) {
            var counter = 0;

            if ( cells[index(i,             upOf(j))    ].isLive === true   ) counter ++;
            if ( cells[index(i,             downOf(j))  ].isLive === true   ) counter ++;
            if ( cells[index(rightOf(i),    j)          ].isLive === true   ) counter ++;
            if ( cells[index(leftOf(i),     j)          ].isLive === true   ) counter ++;
            if ( cells[index(leftOf(i),     upOf(j))    ].isLive === true   ) counter ++;
            if ( cells[index(leftOf(i),     downOf(j))  ].isLive === true   ) counter ++;
            if ( cells[index(rightOf(i),    upOf(j))    ].isLive === true   ) counter ++;
            if ( cells[index(rightOf(i),    downOf(j))  ].isLive === true   ) counter ++;

            if (counter == 3)
                cells[index(i,j)].mustbirth = true;
            else if (counter > 3 || counter < 2)
                cells[index(i,j)].mustdie = true;


        }
    }



}
