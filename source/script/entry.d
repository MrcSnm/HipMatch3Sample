module script.entry;
import script.config;
import script.board;
import hip.api;
import hip.util.conv;

//TODO: Future support for enums (need the recursive folder generator)
// import hip.assetmanager;
// mixin HipAssetsGenerateEnum!("assets");

class MainScene : AScene
{
	Array2D!IHipTextureRegion spritesheet;
	IHipSprite matchTexture;
	Board board;
	/** Constructor */
	override void initialize()
	{
		setFont(null);
		board = new Board();

		Viewport v = getCurrentViewport();
		v.type = ViewportType.fit;
		v.setWorldSize(GAME_WIDTH, GAME_HEIGHT);
		setCameraSize(GAME_WIDTH, GAME_HEIGHT);
		setViewport(v);
		// matchTexture = newSprite("sprites/assets_candy.png");
		// spritesheet = cropSpritesheetRowsAndColumns(matchTexture.getTexture(), 7, 7);
		// matchTexture.setRegion(spritesheet[0,0]);
	}
	/** Called every frame */
	override void update(float dt)
	{
		board.update();
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
		// drawSprite(matchTexture);
		board.draw();
		// drawText("Scripting test!", 100, 100);
		// drawText("First game test?", 100, 200);
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
	