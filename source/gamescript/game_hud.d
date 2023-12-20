module gamescript.game_hud;
import gamescript.gameover;
import hip.game2d.text;
// import gamescript.text;
import gamescript.game;
import gamescript.config;
import hip.util.conv;
import hip.tween;
import hip.api;
import hip.timer;

class GameHud
{
    Game game;

    HipText pressEnter;
    HipText scoreText;
    HipText timeText;
    HipText levelText;
    HipText goalText;



    HipFont font;
    HipFont pressEnterFont;
    HipTimer timer;
    GameOver gameOver;
    private int time = 60;
    private enum rectX = 100;
    private enum rectY = 50;
    private enum rectWidth = 400;

    this(Game game)
    {
        this.game = game;
        font = HipDefaultAssets.getDefaultFontWithSize(62);
        pressEnterFont = HipDefaultAssets.getDefaultFontWithSize(124);
        timer = new HipTimer("Time Subtraction", 1, HipTimerType.oneShot, true)
        .addHandler(&subtractTime);
        uint height  = font.lineBreakHeight;


        static if(InputIsTouch)
            pressEnter = new HipText("Touch to Start the Game", GAME_WIDTH/2, 0, pressEnterFont);
        else
            pressEnter = new HipText("Press Enter to Start the Game", GAME_WIDTH/2, 0, pressEnterFont);
        pressEnter.color = HipColor.black;

        pressEnter.setAlign(HipTextAlign.CENTER, HipTextAlign.CENTER);

        int textX = rectX;

        scoreText = new HipText("Score: 0", textX, 100, font, rectWidth);
        timeText = new HipText("Time: 60", textX, scoreText.y+height, font, rectWidth);
        levelText = new HipText("Level 1", textX, timeText.y+height, font, rectWidth);
        goalText = new HipText("Goal: 1000", textX, levelText.y+height, font, rectWidth);

        foreach(txt; [scoreText, timeText, levelText, goalText])
        {
            txt.setAlign(HipTextAlign.CENTER, HipTextAlign.CENTER);
            txt.color = HipColor.white;
        }
        game.setGameHud(this);
    }

public:
    void showEnterToStartGame()
    {
		HipTimerManager.addTimer(
			HipTween.to!(["y"])(PRESS_ENTER_TWEEN_TIME, pressEnter, [cast(int)(GAME_HEIGHT/2 - pressEnterFont.lineBreakHeight/2)]).setEasing(HipEasing.easeOutBounce).addOnFinish(()
			{

                static if(InputIsTouch)
                {
                    HipInput.addTouchListener(HipMouseButton.any, (meta)
                    {
                        game.onGameStart();
                    }, HipButtonType.down, AutoRemove.yes);
                }
                else
                {
                    HipInput.addKeyboardListener(HipKey.ENTER, (meta)
                    {
                        game.onGameStart();
                    }, HipButtonType.down, AutoRemove.yes);
                }
			})
		);
    }

    void onNextLevel (int duration)
    {
        time = duration;
        timer.setProperties(timer.name, 1, HipTimerType.oneShot, true);
        timer.reset();
    }

    void setScore(int score)
    {
        scoreText.text = "Score: "~ score.to!string;
    }

    void setLevel(int level)
    {
        levelText.text = "Level " ~ level.to!string;
    }
    void setGoal(int goal){goalText.text = "Goal: " ~ goal.to!string;}
    
    void setDuration(int duration)
    {
        time = duration;
        timeText.text = "Time: "~ duration.to!string;
    }

    void update(float deltaTime)
    {
        timer.tick(deltaTime);
    }

    void draw()
    {
        if(!game.hasStarted)
        {
            pressEnter.draw();
        }
        else if(gameOver !is null)
            gameOver.draw();
        else if(game.isPlayingLevel)
        {
            setFont(font);
            ///Rect
            setGeometryColor(HipColor(0.3, 0.3, 0.3, 0.8));
            fillRectangle(rectX, rectY, rectWidth, 250);

            //Info
            scoreText.draw();
            timeText.draw();
            levelText.draw();
            goalText.draw();
        }
    }

    void showGameFinish()
    {
        gameOver = new GameOver(true);
        gameOver.show();
    }
protected:

    void playGameOver()
    {
        gameOver = new GameOver(true);
        gameOver.show();
    }

    void subtractTime()
    {
        import hip.util.conv;
        time-= 1;
        timeText.text = "Time: "~time.to!string;
        if(time <= 0)
        {
            timer.stop();
            playGameOver();
        }
    } 
}