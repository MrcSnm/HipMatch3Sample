module gamescript.level;
import gamescript.config;
import hip.api;
import hip.timer;
import hip.tween;
import hip.util.conv;
import hip.game2d.text;

class Level
{
    int[] subset;
    int targetGoal;
    int duration;
    float rectX = 0, rectY = 0;
    float txtY = 0;
    HipText text;

    enum GREET_RECT_HEIGHT = GAME_HEIGHT/6;

    this(int targetGoal, int duration, int[] subset, int level)
    {
        this.targetGoal = targetGoal;
        this.duration = duration;
        this.subset = subset;
        text = new HipText("Level "~level.to!string, GAME_WIDTH/2, 50);
        text.color = HipColor.white;
        text.font = HipDefaultAssets.getDefaultFontWithSize(62);
        txtY = text.y;
        text.setAlign(HipTextAlign.CENTER, HipTextAlign.CENTER);
    }

    int getPieceType()
    {
        import hip.math.random;
        return Random.select(subset);
    }


    void greetLevel(void delegate() onFinish)
    {
        HipTimerManager.addRenderTimer(new HipTimer("Render Level", 10, HipTimerType.progressive).addHandler(()
        {
            setGeometryColor(HipColor(0.0, 0.5, 0.8, 0.8));
            fillRectangle(cast(int)rectX,cast(int)rectY, GAME_WIDTH, GREET_RECT_HEIGHT);
            text.y = cast(int)txtY;
            text.draw();
        }));

        HipTimerManager.addTimer(new HipSequence("Greet", 
            HipTween.by(1.5f, [&rectY, &txtY], [cast(float)GAME_HEIGHT/2 - GREET_RECT_HEIGHT/2]).setEasing(HipEasing.easeOutBack),
            new HipTimer("Wait", 1),
            HipTween.by(1.5f, [&rectY, &txtY], [cast(float)GAME_HEIGHT/2 + GREET_RECT_HEIGHT/2]).setEasing(HipEasing.easeInBack)
        ).addOnFinish(onFinish));
    }

    

    /**
    *
    *   Format:
    *   subset: x,x,x,x
    *   targetGoal: xxxx
    *   duration: xxxx
    *   //Empty Line
    *   etc...
    */
    static Level[] parseLevels(string levels)
    {
        import hip.util.string;
        import hip.util.algorithm;
        Level[] ret;
        
        int level = 1;
        Level nextLevel = new Level(0, 0, [], level);
        foreach(line; splitRange(levels, "\n"))
        {
            if(line.trim == "")
            {
                ret~= nextLevel;
                nextLevel = new Level(0, 0, [], ++level);
            }
            else if(string data = line.after("subset: "))
            {
                nextLevel.subset = data.splitRange(",").map((string num) => num.to!int).array;
            }
            else if(string data = line.after("targetGoal: "))
            {
                nextLevel.targetGoal = data.to!int;
            }
            else if(string data = line.after("duration: "))
            {
                nextLevel.duration = data.to!int;
            }
        }
        if(nextLevel.duration != 0)
            ret~= nextLevel;
        logg("Found ", ret.length, " levels");
        return ret;
    }
}