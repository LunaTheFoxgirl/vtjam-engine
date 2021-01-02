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
    int fontSize = 16;

public:
    /**
        Color of the label
    */
    vec4 color;

    /**
        Sets the font size
    */
    void setFontSize(int fontSize) {
        this.fontSize = fontSize;
        GameFont.setSize(fontSize);
        boxSize = GameFont.measure(this.label);
    }

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
    
    override void onActivate() { }
    override void onHover() { }
    override void onLeave() { }

    override vec2 getSize() {
        return boxSize;
    }
}