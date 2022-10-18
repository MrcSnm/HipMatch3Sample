module script.board;
import script.config;
import hip.util.conv;
import hip.math.utils;
import hip.api;


private enum spritesheetPath = "sprites/assets_candy.png";
private enum spritesheetRows = 7;
private enum spritesheetColumns = 7;
private enum byte[2] nullPiece = [-1, -1];

class Board
{
    Cursor cursor;
    IHipTexture boardSprites;
    Spritesheet spritesheet;
    IHipTextureRegion[] candies;
    IHipSprite test;
    int[][] board;

    byte[2] selectedPiece = nullPiece;
    private int xOffsetPerCandy;
    private int yOffsetPerCandy;

    this()
    {
        auto texWork = HipAssetManager.loadTexture(spritesheetPath);
        HipAssetManager.awaitLoad();
        cursor = new Cursor(this);
        boardSprites = cast(IHipTexture)texWork.asset;
        spritesheet = cropSpritesheetRowsAndColumns(boardSprites, spritesheetRows, spritesheetColumns);
        board = new int[][](BOARD_SIZE, BOARD_SIZE);
        for(int i = 0; i < 3; i++)
            for(int j = 0; j < 5; j++)
                candies~= spritesheet[i, j];
        
        generateBoard();

        test = newSprite(null);
        test.setTexture(boardSprites);
    }
    protected final void generateBoard()
    {
        for(int i = 0; i < BOARD_SIZE; i++)
        {
            for(int j = 0; j < BOARD_SIZE; j++)
            {
                import hip.util.conv;
                board[i][j] = Random.range(0, cast(int)candies.length - 1);
            }
        }
        xOffsetPerCandy = cast(int)(candies[0].getWidth() * PIECE_DISTANCE_MULTIPLIER);
        yOffsetPerCandy = cast(int)(candies[0].getHeight() * PIECE_DISTANCE_MULTIPLIER);
    }

    final void unselectPiece(){selectedPiece = nullPiece;}

    void selectPiece(ubyte x, ubyte y)
    {
        if(selectedPiece == [x, y])
            unselectPiece();
        else if(selectedPiece != nullPiece)
        {
            if(canMovePieces(selectedPiece[0], selectedPiece[1], x, y))
                swapPieces(selectedPiece[0], selectedPiece[1], x, y);   
            selectedPiece = nullPiece;
        }
        else
            selectedPiece = [x, y];
    }


    bool canMovePieces(ubyte x1, ubyte y1, ubyte x2, ubyte y2)
    {
        if(x1 >= BOARD_SIZE || y1 >= BOARD_SIZE || x2 >= BOARD_SIZE || y2 >= BOARD_SIZE)
            return false;
        
        int xDiff = abs(x1 - x2);
        int yDiff = abs(y1 - y2);
        
        return xDiff + yDiff == 1; //0 means don't move, greater than 1 means diagonal or far swap
    }

    void swapPieces(ubyte x1, ubyte y1, ubyte x2, ubyte y2)
    {
        log("Can move!");
    }

    void update()
    {
        cursor.update();
    }


    void draw()
    {
        // drawSprite(test);
        for(int i = 0; i < BOARD_SIZE; i++)
        {
            for(int j = 0; j < BOARD_SIZE; j++)
            {
                drawRegion(candies[board[i][j]], xOffsetPerCandy * j, yOffsetPerCandy * i);
            }
        }
        if(selectedPiece != nullPiece)
        {
            setGeometryColor(HipColor(1f, 1f, 1f, 0.9f));
            drawRectangle(selectedPiece[0]*100, selectedPiece[1]*100, 100, 100);
        }

        cursor.draw(0,0);
    }
}

class Cursor
{
    ubyte x = 0;
    ubyte y = 0;
    Board board;
    this(Board b)
    {
        board = b;
    }

    void moveTo(ubyte x, ubyte y)
    {
        this.x = cast(ubyte)clamp(x, 0, BOARD_SIZE-1);
        this.y = cast(ubyte)clamp(y, 0, BOARD_SIZE-1);
    }

    void moveX(byte direction)
    {
        x+= direction;

        if(x == ubyte.max)
            x = BOARD_SIZE - 1;
        else if(x >= BOARD_SIZE)
            x = 0;
    }
    void moveY(byte direction)
    {
        y+= direction;
        if(y == ubyte.max)
            y = BOARD_SIZE-1;
        else if(y >= BOARD_SIZE)
            y = 0;
    }

    void select()
    {
        board.selectPiece(x, y);
    }

    void update()
    {
        if(HipInput.isKeyJustPressed('w'))
            moveY(-1);
        else if(HipInput.isKeyJustPressed('s'))
            moveY(1);
        else if(HipInput.isKeyJustPressed('a'))
            moveX(-1);
        else if(HipInput.isKeyJustPressed('d'))
            moveX(1);
        else if(HipInput.isKeyJustPressed(HipKey.ENTER))
            select();
    }

    void draw(int boardX, int boardY, int pieceWidth = 100, int pieceHeight = 100)
    {
        setGeometryColor(HipColor(1f, 1f, 1f, 0.5f));
        drawRectangle(boardX + pieceWidth*x, boardY + pieceHeight*y, 100, 100);
    }
}