module gamescript.gameover;
import hip.api;
import gamescript.config;
import hip.tween;

class GameOver
{
    bool gameWon;
    float alpha = 0;
    this(bool gameWon)
    {
        this.gameWon = gameWon;
    }
    void show()
    {
        HipTimerManager.addTimer(HipTween.to(1, [&alpha], [1]));
    }
    void draw()
    {
        fillRectangle(0,0, GAME_WIDTH, GAME_HEIGHT, HipColor(0,0,0,cast(ubyte)(alpha*255)));
        drawText(gameWon ? "Thanks for playing!" : "Game Over!", GAME_WIDTH/2, GAME_HEIGHT/2, HipColor.alpha(alpha));
    }
}