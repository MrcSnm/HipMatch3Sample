module script.entry;
import hip.api;
import hip.util.conv;
import hip.tween;
import hip.timer;

import script.config;
import script.board;
import script.text;
import script.background;

//TODO: Future support for enums (need the recursive folder generator)
// import hip.assetmanager;
// mixin HipAssetsGenerateEnum!("assets");

class MainScene : AScene
{
	Board board;
	Text text;
	Background background;
	bool hasStarted;

	/** Constructor */
	override void initialize()
	{
		setFont(null);
		board = new Board();
		Viewport v = getCurrentViewport();
		background = new Background();
		v.type = ViewportType.fit;
		v.setWorldSize(GAME_WIDTH, GAME_HEIGHT);
		setCameraSize(GAME_WIDTH, GAME_HEIGHT);
		setViewport(v);

		text = new Text("Press Enter to Start the Game", GAME_WIDTH/2, 0);

		HipTimerManager.addTimer(
			HipTween.to!(["y"])(2.5, text, [GAME_HEIGHT/4]).setEasing(HipEasing.easeOutBounce).addOnFinish(()
			{
				HipInput.addKeyboardListener(HipKey.ENTER, (meta)
				{
					startGame();
				}, HipButtonType.down, AutoRemove.yes);
			})
		);
	}
	void startGame()
	{
		hasStarted = true;
		logg("Game started");
		background.fade();
	}

	/** Called every frame */
	override void update(float dt)
	{
		if(hasStarted)
			board.update(dt);
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
		background.draw();
		if(hasStarted)
			board.draw();
		text.draw();
		renderTexts();
		renderSprites();
	}
	/** Pre destroy */
	override void dispose()
	{
		
	}

	void pushLayer(Layer l){}
	void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;
	