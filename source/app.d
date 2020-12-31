module app;
import engine;
import std.stdio;
import config;

void _init() {
}

void _update() {
    kmClearColor(vec4(0, 0, 0, 1));
}

void _cleanup() {

}

void _border() {
    kmClearColor(vec4(0.5, 0.5, 0.5, 1));
}

void _postUpdate() {

}

int main() {

    // Set 
    gameInit = &_init;
    gameUpdate = &_update;
    gameCleanup = &_cleanup;
    gameBorder = &_border;

    // Init engine start the game and then close the engine once the game quits
    initEngine();
    startGame(vec2i(TARGET_WIDTH, TARGET_HEIGHT));
    closeEngine();
    return 0;
}