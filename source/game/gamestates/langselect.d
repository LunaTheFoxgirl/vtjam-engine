module game.gamestates.langselect;
import engine;
import game;

class LanguageSelectState : GameState {
private:
    void setContent() {
        selectLanguageLabel.setText(_("Select Language"));
        englishButton.setText(_("English"));
        japaneseButton.setText(_("Japanese"));

        selectLanguageLabel.setFontSize(kmGetDefaultFontSize()*2);

        placeWidgetCentered(selectLanguageLabel, 8);
        placeWidgetCentered(englishButton, 64);
        placeWidgetCentered(japaneseButton, 64+32);
        
        // Make box smaller
        surface.area = surface.getContentArea();
        surface.area.height += 8;
        
        // Move box to center
        surface.area.x = (kmCameraViewWidth/2)-(surface.area.width/2);
        surface.area.y = (kmCameraViewHeight/2)-(surface.area.height/2);
    }

    void placeWidgetCentered(Widget widget, float y) {
        auto widgetSize = widget.getSize();
        widget.position.y = cast(int)y;
        widget.position.x = cast(int)((surface.area.width/2)-(widgetSize.x/2));
    }

    InWidgetSurface surface;
    Label selectLanguageLabel;
    TextButton englishButton;
    TextButton japaneseButton;

    string chosenLanguage;

    void onHoverEnglish() {
        if (surface is null) return;

        kmSetLanguage("English");
        GlobalConfig.lang = "English";
        this.setContent();
    }

    void onHoverJapanese() {
        if (surface is null) return;

        kmSetLanguage("Japanese");
        GlobalConfig.lang = "Japanese";
        this.setContent();
    }

    void onLanguageSelected() {
        // Save to config and close the language selection
        kmSaveConfig();
        GameStateManager.pop();
        SurfaceStack.pop();
    }

public:
    override void onActivate() {
        AppLog.info("Surface", "%s %s", kmCameraViewWidth, kmCameraViewHeight);

        auto surfaceRect = Rect(
            0, 
            0, 
            256, 
            256
        );

        selectLanguageLabel = new Label("", vec2i(0, 0), 0);
        englishButton = new TextButton("", vec2i(0, 0), &onLanguageSelected, &onHoverEnglish);
        japaneseButton = new TextButton("", vec2i(0, 0), &onLanguageSelected, &onHoverJapanese);

        surface = new InWidgetSurface(surfaceRect, [
            selectLanguageLabel,
            englishButton,
            japaneseButton
        ]);
        surface.setShowBorder(false);
        this.setContent();

        SurfaceStack.push(surface);
    }

    override void update() {

    }

    override void draw() {

    }
}
