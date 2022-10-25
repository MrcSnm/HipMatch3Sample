module script.piece;
import hip.api;

class Piece
{
    float x, y;
    int type;
    ubyte gridX, gridY;
    IHipTextureRegion region;

    this(int type, IHipTextureRegion region, float startX, float startY, ubyte gridX, ubyte gridY)
    {
        this.type = type;
        this.region = region;
        x = startX;
        y = startY;
        this.gridX = gridX;
        this.gridY = gridY;
    }

    void swapGridPosition(Piece piece)
    {
        import hip.util.algorithm;
        swap(gridX, piece.gridX);
        swap(gridY, piece.gridY);
    }

    void draw()
    {
        if(region !is null)
            drawRegion(region, cast(int)x, cast(int)y);
    }
}