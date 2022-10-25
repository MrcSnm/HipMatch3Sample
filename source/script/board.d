module script.board;
import script.config;
import script.piece;
import hip.util.conv;
import hip.math.utils;
import hip.api;
import hip.util.algorithm;
import hip.tween;


private enum spritesheetPath = "sprites/assets_candy.png";
private enum explosionPath = "sprites/explotion.png";
private enum spritesheetRows = 7;
private enum spritesheetColumns = 7;
private enum byte[2] nullPiece = [-1, -1];

class Board
{
    Cursor cursor;
    IHipTexture boardSprites;
    Spritesheet spritesheet;
    IHipTextureRegion[] candies;
    Piece[][] board;

    IHipAnimationTrack explosionAnimation;
    IHipTexture explosionTexture;

    bool canInput = true;
    byte[2] selectedPiece = nullPiece;
    private int xOffsetPerCandy;
    private int yOffsetPerCandy;


    this()
    {
        auto texWork = HipAssetManager.loadTexture(spritesheetPath);
        auto exploTexWork = HipAssetManager.loadTexture(explosionPath);
        HipAssetManager.awaitLoad();
        cursor = new Cursor(this);
        boardSprites = cast(IHipTexture)texWork.asset;
        explosionTexture = cast(IHipTexture)exploTexWork.asset;

        
        explosionAnimation = newHipAnimationTrack("Explosion", 24, false)
            .addFrames(
                cropSpritesheetRowsAndColumns(explosionTexture, 2, 4)
            );

        import hip.util.conv;
        spritesheet = cropSpritesheetRowsAndColumns(boardSprites, spritesheetRows, spritesheetColumns);
        board = new Piece[][](BOARD_SIZE, BOARD_SIZE);
        for(int i = 0; i < 3; i++)
            for(int j = 0; j < 5; j++)
                candies~= spritesheet[i, j];
        
        generateBoard();
    }
    protected final void generateBoard()
    {
        xOffsetPerCandy = cast(int)(candies[0].getWidth() * PIECE_DISTANCE_MULTIPLIER);
        yOffsetPerCandy = cast(int)(candies[0].getHeight() * PIECE_DISTANCE_MULTIPLIER);

        for(ubyte y = 0; y < BOARD_SIZE; y++)
        {   
            for(ubyte x = 0; x < BOARD_SIZE; x++)
            {
                import hip.util.conv;
                int type = Random.range(0, cast(int)candies.length - 1);
                board[y][x] = new Piece(type, candies[type], xOffsetPerCandy*x, yOffsetPerCandy*y, x, y);
            }
        }

        board[0][0] = new Piece(0, candies[0], 0, 0, 0, 0);
        board[1][0] = new Piece(0, candies[0], 0, yOffsetPerCandy*1, 0, 1);
        board[2][0] = new Piece(0, candies[0], 0, yOffsetPerCandy*2, 0, 2);
    }

    final void unselectPiece(){selectedPiece = nullPiece;}

    void selectPiece(ubyte x, ubyte y)
    {
        if(!canInput)
            return;
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

    bool calculateMatches(out Piece[3][] matches)
    {
        for(int y = 0; y < BOARD_SIZE; y++)
        {
            int matchCount = 1;
            for(int x = 1; x < BOARD_SIZE; x++) 
            {
                if(board[y][x] is null || board[y][x-1] is null)
                {
                    matchCount = 1;
                    continue;
                }
                if(board[y][x].type == board[y][x-1].type)
                {
                    if(++matchCount == 3)
                    {
                        matches~= [board[y][x-2], board[y][x-1], board[y][x]];
                        matchCount = 1;
                    }
                }
                else
                    matchCount = 1;
            }
        }

        for(int x = 0; x < BOARD_SIZE; x++) 
        {
            int matchCount = 1;
            for(int y = 1; y < BOARD_SIZE; y++)
            {
                if(board[y][x] is null || board[y-1][x] is null)
                {
                    matchCount = 1;
                    continue;
                }
                if(board[y][x].type == board[y-1][x].type)
                {
                    if(++matchCount == 3)
                    {
                        matches~= [board[y-2][x], board[y-1][x], board[y][x]];
                        matchCount = 1;
                    }
                }
                else
                    matchCount = 1;
            }
        }
        return matches.length != 0;
    }


    bool canMovePieces(ubyte x1, ubyte y1, ubyte x2, ubyte y2)
    {
        if(x1 >= BOARD_SIZE || y1 >= BOARD_SIZE || x2 >= BOARD_SIZE || y2 >= BOARD_SIZE)
            return false;
        
        int xDiff = abs(x1 - x2);
        int yDiff = abs(y1 - y2);
        
        return xDiff + yDiff == 1; //0 means don't move, greater than 1 means diagonal or far swap
    }

    ///Returns if any piece has fallen
    bool makePiecesFall()
    {
        bool anyFall = false;
        HipSpawn spawn;
        for(int x = 0; x < BOARD_SIZE; x++)
        {
            //The target must be the board's end
            int targetY = BOARD_SIZE - 1;
            for(int y = BOARD_SIZE - 1; y >= 0; y--)
            {
                if(board[y][x] is null)
                    continue;
                else
                {
                    if(targetY != y) //If there is no in between them, no need to swap
                    {
                        anyFall = true;
                        int yDiff = targetY - y;
                        Piece p = board[y][x];
                        p.gridY = cast(ubyte)targetY;

                        if(spawn is null)
                        {
                            spawn = new HipSpawn();
                        }

                        spawn.add(
                            HipTween.by!(["y"])(0.1, p, [yDiff * 100])
                        );
                        swap(board[targetY][x], board[y][x]);
                    }
                    targetY-= 1; //The last empty space will be the one up above
                }
            }
        }
        if(anyFall)
        {
            canInput = false;
            HipTimerManager.addTimer(spawn.addOnFinish(()
            {
                canInput = true;
                logg("Finished!", canInput);
                updateBoard();
            }));
        }
        return anyFall;
    }

    protected void updateBoard()
    {
        Piece[3][] matches;
        if(calculateMatches(matches))
        {
            foreach(match; matches)
            {
                foreach(piece; match)
                {
                    HipGameUtils.playAnimationAtPosition(cast(int)piece.x, cast(int)piece.y, explosionAnimation, 0.1, 0);
                    board[piece.gridY][piece.gridX] = null;
                }
            }
            makePiecesFall();
        }
    }
    protected void onSwapFinish()
    {
        canInput = true;
        updateBoard();
    }

    void swapPieces(ubyte x1, ubyte y1, ubyte x2, ubyte y2)
    {
        if(!canInput)
            return;
        canInput = false;
        Piece a = board[y1][x1];
        Piece b = board[y2][x2];
        swap(board[y1][x1], board[y2][x2]);
        a.swapGridPosition(b);
        

        HipTimerManager.addTimer(
            new HipSpawn(
                HipTween.to!(["x", "y"])(PIECE_SWAP_TIME, a, [b.x, b.y]),
                HipTween.to!(["x", "y"])(PIECE_SWAP_TIME, b, [a.x, a.y])
            ).addOnFinish((){onSwapFinish();})
        );
    }

    void update(float deltaTime)
    {
        cursor.update();
    }


    void draw()
    {
        for(int i = 0; i < BOARD_SIZE; i++)
        {
            for(int j = 0; j < BOARD_SIZE; j++)
            {
                if(board[i][j] !is null)
                    board[i][j].draw();
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