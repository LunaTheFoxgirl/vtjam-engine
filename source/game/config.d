module game.config;
import engine;
import std.path;
import std.file;
import std.string;
import std.utf;
import asdf;
import config;

version(posix) {
    string getGameConfigFolder() {
        return expandTilde("~/.vtjam");
    }

    string getGameConfigPath() {
        return expandTilde("~/.vtjam/config.json");
    }
}

version(Windows) {
    pragma(lib, "user32.lib");
    pragma(lib, "shell32.lib");

    private string getDocuments() {
        import core.sys.windows.windows;
        import core.sys.windows.shlobj;
        wstring documentsDir = new wstring(MAX_PATH);
        SHGetSpecialFolderPath(HWND_DESKTOP, cast(wchar*)documentsDir.ptr, CSIDL_PERSONAL, FALSE);
        return (cast(wstring)fromStringz!wchar(documentsDir.ptr)).toUTF8;
    }

    string getGameConfigPath() {
        return buildPath(getDocuments(), "My Games", "VTJam", "config.json");
    }

    string getGameConfigFolder() {
        return buildPath(getDocuments(), "My Games", "VTJam");
    }
}

/**
    Global config instance
*/
Config GlobalConfig;

/**
    Saves the game's configuration
*/
void kmSaveConfig() {
    AppLog.info("Game", "Configuration saved!");

    mkdirRecurse(getGameConfigFolder());
    write(getGameConfigPath(), serializeToJsonPretty(GlobalConfig));
}

/**
    Tries to load configuration file

    returns true if successful, false if not
*/
bool kmLoadConfig() {
    GlobalConfig = new Config;
    mkdirRecurse(getGameConfigFolder());

    // No config files to load
    if (!exists(getGameConfigPath())) return false;

    GlobalConfig = deserialize!Config(readText(getGameConfigPath()));
    return true;
}

/**
    The game's configuration
*/
class Config {

    /**
        Game's language
    */
    string lang;

    /**
        Music volume
    */
    @serdeOptional
    float musicVolume = BaseMusicVolume;

    /**
        SFX volume
    */
    @serdeOptional
    float sfxVolume = BaseSFXVolume;
}