module app;
import engine;
import config;
import game;
import std.format;

void _init() {
    if (!kmLoadConfig()) GameStateManager.push(new LanguageSelectState);
    else GameStateManager.push(new InGameState);
}

void _update() {
    // Draw game states
    GameStateManager.update();
    GameStateManager.draw();

    // Draw surface stack
    SurfaceStack.update();
    SurfaceStack.draw();
}

void _cleanup() {

}

void _border() {

}

void _postUpdate() {

    UI.resetTextSize();
    GameFont.draw("%sms"d.format(cast(int)(deltaTime()*100)), vec2(4, 4));
    GameFont.flush();
}

int main() {

    // Set 
    gameInit = &_init;
    gameUpdate = &_update;
    gamePostUpdate = &_postUpdate;
    gameCleanup = &_cleanup;
    gameBorder = &_border;

    // Init engine start the game and then close the engine once the game quits
    initEngine();
    startGame(vec2i(TARGET_WIDTH, TARGET_HEIGHT));
    closeEngine();
    return 0;
}