/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.ui.widget;
import engine.ui.surface;
import engine;
import std.algorithm.mutation : remove;
import bindbc.opengl;
import std.exception;
import std.format;

/**
    The different states a widget can be in
*/
enum WidgetState {
    /**
        When the widget is normal
    */
    Normal,

    /**
        When the widget is hovered
    */
    Hover,

    /**
        When the widget is selected
    */
    Activated
}

/**
    A widget
*/
abstract class Widget {
private:
    string typeName;
    WidgetSurface surface;

protected:
    WidgetState state;

    /**
        Base widget instance requires type name
    */
    this(string type, vec2i position) {
        this.typeName = type;
        this.position = position;
    }

    /**
        Code run when updating the widget
    */
    abstract void onUpdate();

    /**
        Code run when drawing
    */
    abstract void onDraw();
    
    /**
        Called when activated
    */
    abstract void onActivate();
    
    /**
        Called when activated
    */
    abstract void onHover();
    
    /**
        Called when activated
    */
    abstract void onLeave();

    /**
        Whether the widget should accept inputs
    */
    bool shouldTakeInput() {
        return state == WidgetState.Hover;
    }

package(engine.ui):
    void setState(WidgetState state) {
        this.state = state;
    }

    void setSurface(WidgetSurface surface) {
        this.surface = surface;
    }

public:

    /**
        Gets the state of the widget
    */
    WidgetState getState() {
        return state;
    }

    /**
        Whether the widget can be interacted with
    */
    bool interactible = true;

    /**
        Whether the widget is visible
    */
    bool visible = true;

    /**
        The position of the widget
    */
    vec2i position = vec2i(0);

    /**
        Update the widget

        Automatically updates all the children first
    */
    final void update() {
        // Update ourselves
        this.onUpdate();
    }

    /**
        Gets the position in relation to the surface this widget is on
    */
    vec2i actualPosition() {
        return vec2i(
            cast(int)(position.x+surface.area.x),
            cast(int)(position.y+(surface.area.y-surface.getScroll()))
        );
    }

    /**
        Draw the widget

        For widget implementing: override onDraw
    */
    final void draw() {

        // Don't draw this widget or its children if we're invisible
        if (!visible) return;

        // Draw ourselves first
        this.onDraw();
    }

    /**
        Call to activate the widget
    */
    final void activate() { 

        // Activating will always set the activated state
        this.setState(WidgetState.Activated);

        onActivate();

        // We should generally be hovering once we're done
        // Though in case calling this activation has changed the widget state
        // We don't want to tramble on it
        if (state == WidgetState.Activated) this.setState(WidgetState.Hover);
    }

    /**
        Tell the widget it has been hovered over
    */
    final void hover() { onHover(); }

    /**
        Tell the wiget that we have left them
    */
    final void leave() { onLeave(); }

    /**
        Calculate and get size of widget
    */
    abstract vec2 getSize();
}