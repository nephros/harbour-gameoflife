/* This script file handles the game logic */
.pragma library
.import "./settings.js" as Settings

var blockSize   = 40
var Inited = false


var maxColumn   = 10;
var maxRow      = 10;
var maxIndex    = 100;

var old_maxColumn   = 10;
var old_maxRow      = 10;
var old_maxIndex    = 100;

var cells = [];
var buf = [];


function Cell(i_, j_) {
    this.isLive = false;
    this.mustdie = false;
    this.mustbirth = false;
    this.i = i_;
    this.j = j_;
}

function createCells() {

    cells = [];
    for (var i = 0; i < 100; i++) {
        for (var j = 0; j < 100; j++) {
            cells.push(new Cell(i,j));
        }
    }


}

function reInitArea(areaWidth, areaHeight) {

    if(Inited) {
        buf = new Array(maxColumn)
        for (var i = 0; i < maxColumn; i++) {
            buf[i] = new Array(maxRow)
            for (var j = 0; j < maxRow; j++) {
                buf[i][j] = cells[index(i,j)].isLive;
            }
        }
    }

    maxColumn   =   Math.floor(areaWidth / blockSize);
    maxRow      =   Math.floor(areaHeight / blockSize);
    maxIndex    =   maxColumn*maxRow;

    if(Inited && buf.length > 0) {
        for (var i = 0; i < maxColumn; i++) {
            for (var j = 0; j < maxRow; j++) {
                cells[index(i,j)].isLive = false
            }
        }

        for (var i = 0; i < maxColumn; i++) {
            for (var j = 0; j < maxRow; j++) {
                if(i < old_maxColumn && j < old_maxRow )
                    cells[index(i,j)].isLive = buf[i][j];
            }
        }
    }



    old_maxColumn = maxColumn;
    old_maxRow = maxRow;
    old_maxIndex = maxIndex;

    Inited = true
}


function index(column, row)
{
    return column + row * maxColumn;
}

function old_index(column, row)
{
    return column + row * old_maxColumn;
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
            var n = index (i,j)

            if(cells[n] instanceof Cell) {
                if ( cells[n].isLive === true ) {
                    ctx.fillStyle =  Qt.rgba(1,1,1,1) ;
                    ctx.fillRect(rectX ,rectY, blockSize, blockSize);
                    if(cells[n].mustdie) {
                        ctx.fillStyle = Qt.rgba(1,0.5,0.5,1);
                        ctx.fillRect(rectX +  blockSize*0.25 ,rectY  +  blockSize*0.25, blockSize*0.5, blockSize*0.5);
                    }


                }
                else if ( cells[n].mustbirth === true ) {
                    ctx.fillStyle = Qt.rgba(0,1,0,0.25);
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

    var i, j, n;



    for ( i = 0; i < maxColumn; i++) {
        for ( j = 0; j < maxRow; j++) {
            n = index(i,j);
            if (cells[n].mustdie && cells[index(i,j)].isLive ) {
                cells[n].isLive = false;
                cells[n].mustdie = false;

            }
            if (cells[n].mustbirth && !cells[index(i,j)].isLive) {
                cells[n].isLive = true;
                cells[n].mustbirth = false;
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

            n = index(i,j);
            if (counter == 3)
                cells[n].mustbirth = true;
            else if (counter > 3 || counter < 2)
                cells[n].mustdie = true;


        }
    }



}
