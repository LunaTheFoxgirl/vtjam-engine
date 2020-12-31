/*
    Scripting Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.scripting;
public import engine.scripting.script;
public import as;
public import as.addons.str : StringPtr;
import as.addons.str;


/**
    State of scripting engine
*/
ScriptEngine ScriptState;

static this() {

    // Create the script state
    ScriptState = ScriptEngine.create();
    
    // Set up script state and pool
    ScriptExec = ScriptState.createContext();

    // We want D string support.
    ScriptState.registerDStrings();

    // Register standard print function
    ScriptState.registerGlobalFunction("void print(const string &in line)", &print);
}

/**
    Angelscript standard print function
*/
void print(ref string text) {
    import engine;
    AppLog.info("Script", text);
}