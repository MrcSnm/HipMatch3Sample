
module script.entry;
import hip.api;
import hip.util.conv;

class MainScene : AScene
{
	
	/** Constructor */
	override void initialize()
	{
		setFont(null);
	}
	/** Called every frame */
	override void update(float dt)
	{
	}
	/** Renderer only, may not be called every frame */
	override void render()
	{
		drawText("Scripting test!", 100, 100);
		drawText("First game test?", 100, 200);
		renderTexts();
	}
	/** Pre destroy */
	override void dispose()
	{
		
	}

	void pushLayer(Layer l){}
	void onResize(uint width, uint height){}
}

mixin HipEngineMain!MainScene;
	