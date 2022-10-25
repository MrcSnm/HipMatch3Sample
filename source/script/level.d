module script.level;
import hip.api;

class Level
{
    int[] subset;
    int targetGoal;
    int duration;
    Spritesheet spritesheet;

    this(Spritesheet spritesheet, int targetGoal, int duration, int[] subset)
    {
        this.subset = subset;
        this.spritesheet = spritesheet;
        this.duration = duration;
        this.subset = subset;
    }

    void greetLevel()
    {
        
    }
}