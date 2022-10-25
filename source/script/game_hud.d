module script.game_hud;
import script.text;

class GameHud
{
    import hip.util.conv;
    Text scoreText;
    Text timeText;
    Text levelText;
    Text goalText;
    this()
    {
        scoreText = new Text("Score: 0", 100, 100);
        timeText = new Text("Time: 60", 100, 200);
        levelText = new Text("Level 1", 100, 300);
        goalText = new Text("Goal: 1000", 100, 400);
    }


    void setScore(int score)
    {
        scoreText.setText("Score: ", score);
    }

    void setTime(int time)
    {
        timeText.setText("Time: ", time);
    }
    void setLevel(int level)
    {
        levelText.setText("Level ", level);
    }
    void setGoal(int goal){goalText.setText("Goal: ", goal);}

    void draw()
    {
        scoreText.draw();
        timeText.draw();
        levelText.draw();
        goalText.draw();
    }
}