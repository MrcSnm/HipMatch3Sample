module script.text;
import hip.api;

class Text
{
    float x, y;
    string text;
    HipColor color = HipColor.white;
    IHipFont font;

    this(string text, float x, float y)
    {
        this.text = text;
        this.x = x;
        this.y = y;
    }

    void setText(Args...)(string text, Args args)
    {
        import hip.util.conv;
        foreach(arg; args)
            text~= arg.to!string;
        this.text = text;
    }

    void draw()
    {
        drawText(text, cast(int)x, cast(int)y);
    }
}