/*
    Internationalization Subsystem

    Copyright © 2020, Luna Nielsen
    Distributed under the 2-Clause BSD License, see LICENSE file.
    
    Authors: Luna Nielsen
*/
module engine.i18n;
import engine;
import std.exception;
import asdf;

// Translation ID
private struct transidx {
    string file;
    int line;
}

// The language file serialization construct
private struct LangFile {
    string name;
    string font;
    string[string] table;
}

// List of languages
private string[string] langList;

// The translation table
__gshared private string[transidx] transtable;

private void genLangList() {
    import std.path;
    import std.file : dirEntries, SpanMode, isDir, exists, mkdir, DirEntry, readText;

    // Create an empty language directory if none exists already.
    if (!exists("lang/")) mkdir("lang/");

    // Go through every language and add them to the list
    foreach(DirEntry trFile; dirEntries(buildPath("lang"), SpanMode.shallow, true)) {
        
        // Skip any stray directories
        if (trFile.isDir) continue;

        Asdf jsonObject = parseJson(readText(trFile.name));
        string langName = jsonObject["name"].get!string(null);

        langList[langName] = trFile;
    }
}

/**
    Gets a list of the languages currently available
*/
string[] kmGetLanguages() {
    string[] langs;
    foreach(name, _; langList) {
        langs ~= name;
    }
    return langs;
}

/**
    Sets the current language
*/
void kmSetLanguage(string language, bool ignoreFontSwitch = false) {
    import std.file : readText, exists;
    import std.path : buildPath, setExtension;
    import std.string : split;
    import std.conv : to;

    transtable.clear();

    if (language !in langList) {
        if (language != "English") AppLog.warn("i18n", "Language %s not found, switching to English...");
        if (!ignoreFontSwitch) kmSwitchFont("default");
        return;
    }

    // Read and parse the json
    string json = langList[language].readText();
    LangFile table = deserialize!LangFile(json);

    // Switch font to the one specified in lang file
    if (!ignoreFontSwitch) kmSwitchFont(table.font);
    
    // Iterate over all the keys and build the LangFile object from it
    foreach(idx, str; table.table) {
        string[] components = idx.split(":");

        // There has to be 2 components seperated by :
        enforce(components.length == 2, "Invalid translation index \""~idx~"\"");

        // Set the translation for the translation index parsed from the components
        // NOTE: File is component 0, Line is component 1
        transtable[transidx(components[0], components[1].to!int)] = str;
    }

    AppLog.info("i18n", "Loaded language %s...", table.name);
}

/**
    Returns a translated string, defaults to the given text if no translation was found
*/
string _(string file=__FILE__, int line = __LINE__)(string text) {

    import std.path : baseName;

    // No translation was loaded
    if (transtable.length == 0) return text;

    transidx idx = transidx(baseName(file), line);

    // Line was not found in translation
    if (idx !in transtable) return text;

    // Line was found, get translation
    return transtable[idx];
}

shared static this() {
    genLangList();
}