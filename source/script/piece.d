module script.piece;
import hip.api;

class Piece
{
    float x, y;
    int type;
    IHipTextureRegion region;

    this(int type, IHipTextureRegion region, float startX, float startY)
    {
        this.type = type;
        this.region = region;
        x = startX;
        y = startY;
    }

    void draw()
    {
        if(region !is null)
            drawRegion(region, cast(int)x, cast(int)y);
    }
}