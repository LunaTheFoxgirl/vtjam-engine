module engine.ui.widgets.button;
import engine.ui;
import engine;

/**
    A text based button
*/
class TextButton : Widget {
private:
    dstring label;
    vec2 size;
    vec4 color;

    void delegate() activateFunc;

public:
    /**
        Sets the text of the label
    */
    void setText(string text) {
        UI.resetTextSize();
        this.label = toEngineString(text);
        size = GameFont.measure(this.label);
    }

    /**
        Instantiates a button
    */
    this(string label, vec2i loc = vec2i(0), void delegate() activateFunc = null) {
        super("Button", vec2i(loc.x, loc.y));

        this.activateFunc = activateFunc;
        this.setText(label);

        // We want to set color to "disabled" if the widget is disabled
        if (!this.interactible) 
            color = vec4(0.5, 0.5, 0.5, 1);
        color = vec4(1, 1, 1, 1);
    }

    override void onUpdate() {

        // Button should just skip out if we're not hovered
        if (!this.shouldTakeInput()) return;

        // Activate the button if enter is pressed
        if (UI.isKeyPressed(Key.KeyReturn)) activate();
    }

    override void onDraw() {
        UI.resetTextSize();
        GameFont.draw(label, vec2(this.actualPosition()), color);
        GameFont.flush();
    }
    
    override void onActivate() {
        color = vec4(0.8, 0.8, 0.1, 1);
        if (activateFunc !is null) activateFunc();
    }

    override void onHover() {
        color = vec4(0.8, 0.8, 0.05, 1);
    }

    override void onLeave() {
        color = vec4(1, 1, 1, 1);
    }

    override vec2 getSize() {
        return size;
    }
}