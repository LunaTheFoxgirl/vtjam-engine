/*
    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.core.astack;
import std.exception;

/**
    A stack of actions performed in the game

    Actions can be undone and redone.
    Pushing a new action to the stack will overwrite actions past the current top cursor.
*/
class ActionStack(ActionT) {
private:
    ActionT[] stack;
    size_t top;

public:

    /**
        Push an action to the stack
    */
    ActionT push(ActionT item) {

        // First remove any elements in the undo/redo chain after our top
        stack.length = top+1;

        // Move the top up one element
        top++;

        // Add new item
        stack ~= item;
        return stack[$-1];
    }

    /**
        Get the current top of the stack
    */
    ActionT get() {
        return stack[top];
    }

    /**
        Undo an action
    */
    ActionT undo() {
        if (top > 0) top--;
        return stack[top];
    }

    /**
        Redo an action
    */
    ActionT redo() {
        if (top < stack.length) top++;
        return stack[top];
    }

    /**
        Returns true if there's any actions left to undo
    */
    bool canUndo() {
        return top > 0;
    }

    /**
        Returns true if there's any actions left to redo
    */
    bool canRedo() {
        return top < stack.length;
    }
}