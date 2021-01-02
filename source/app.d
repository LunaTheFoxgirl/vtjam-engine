module app;
import engine;
import config;
import game;

void _init() {
    if (!kmLoadConfig()) GameStateManager.push(new LanguageSelectState);
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