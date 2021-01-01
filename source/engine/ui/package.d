/*
    UI Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.ui;
public import engine.ui.widget;
public import engine.ui.widgets;
public import engine.ui.surface;
import engine;
import bindbc.opengl;
import core.memory;

/**
    Base stuff for UI rendering
*/
class UI {
private static:
    KeyboardState* lstate;
    KeyboardState* cstate;

package(engine):
    /**
        Gets whether a keyboard key has been pressed down
    */
    static bool isKeyPressed(Key key) {
        return cstate.isKeyDown(key) && lstate.isKeyUp(key);
    }

    /**
        Updates internal keyboard state
    */
    static void update() {
        lstate = cstate;
        cstate = Keyboard.getState();
    }

public static:

    /**
        Resets the scale of text elements
    */
    static void resetTextSize() {
        GameFont.setSize(16);
    }
    
    /**
        Sets up state for UI rendering
    */
    static void begin() {
        glEnable(GL_SCISSOR_TEST);
        resetTextSize();
    }

    /**
        Set the UI scissor area
    */
    static void setScissor(Rect scissor) {
        Rect actualScissor = Rect(scissor.x*2, scissor.y*2, scissor.width*2, scissor.height*2);
        glScissor(
            actualScissor.x, 
            (kmViewportHeight-actualScissor.y)-actualScissor.height, 
            cast(uint)actualScissor.width, 
            cast(uint)actualScissor.height
        );
    }

    /**
        Finishes up UI rendering state
    */
    static void end() {
        glDisable(GL_SCISSOR_TEST);
    }
}