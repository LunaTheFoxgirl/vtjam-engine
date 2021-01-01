module engine.ui.widgets.label;
import engine.ui;
import engine;

/**
    A text based button
*/
class Label : Widget {
private:
    dstring label;
    vec2 boxSize;
    vec4 color;
    int fontSize = 16;

public:

    /**
        Sets the text of the label
    */
    void setText(string text) {
        GameFont.setSize(fontSize);
        this.label = toEngineString(text);
        boxSize = GameFont.measure(this.label);
        UI.resetTextSize();
    }

    /**
        Instantiates a button
    */
    this(string label, vec2i loc, int size = 16, vec4 color = vec4(1)) {
        super("Label", vec2i(loc.x, loc.y));
        this.fontSize = size;
        this.interactible = false;
        this.color = color;

        // Set the text of the label
        this.setText(label);
    }

    // This thing does nothing
    override void onUpdate() { }

    override void onDraw() {
        GameFont.setSize(fontSize);
        GameFont.draw(label, vec2(this.actualPosition()), color);
        GameFont.flush();

        // Reset text size so other elements don't get scaled up weirdly
        UI.resetTextSize();
    }
    
    override void onActivate() {
        color = vec4(0.8, 0.8, 0.1, 1);
    }

    override void onHover() {
        color = vec4(0.8, 0.8, 0.05, 1);
    }

    override void onLeave() {
        color = vec4(1, 1, 1, 1);
    }

    override vec2 getSize() {
        return boxSize;
    }
}