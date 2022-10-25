module script.background;
import hip.api;
import hip.tween;

enum backgroundPath = "images/background.png";
enum backgroundBlurPath = "images/background_blur.png";

class Background
{
    protected IHipTexture bkg;
    protected IHipTexture bkgBlur;

    float bkgOpacity = 1;
    float bkgBlurOpacity = 0;

    this()
    {
        bkg = HipAssetManager.loadTexture(backgroundPath).awaitAs!IHipTexture;
        bkgBlur = HipAssetManager.loadTexture(backgroundBlurPath).awaitAs!IHipTexture;

    }
    void fade()
    {
        HipTimerManager.addTimer(HipTween.to!(["bkgOpacity", "bkgBlurOpacity"])(2.5, this, [0.0, 1.0]));
    }
    void draw()
    {
        drawTexture(bkg, 0, 0, 0, HipColor(1, 1, 1, bkgOpacity));
        drawTexture(bkgBlur, 0, 0, 0, HipColor(1, 1, 1, bkgBlurOpacity));
    }    
}