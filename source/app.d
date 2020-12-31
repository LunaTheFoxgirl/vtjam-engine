module app;
import engine;
import std.stdio;
import config;

class Ritta {
private:
    Texture texture;
    vec2 position;

public:
    this() {
        texture = new Texture("assets/ritta.png");
        texture.setFiltering(Filtering.Point);
    }

    void update() {
        auto keyboardState = Keyboard.getState();

        if (keyboardState.isKeyDown(Key.KeyW)) {
            position.y -= 4;
        } else if (keyboardState.isKeyDown(Key.KeyS)) {
            position.y += 4;
        }

        if (keyboardState.isKeyDown(Key.KeyA)) {
            position.x -= 4;
        } else if (keyboardState.isKeyDown(Key.KeyD)) {
            position.x += 4;
        }
        auto texCenter = texture.center();
        

        position.x = clamp(position.x, texCenter.x, PlayfieldWidth-texCenter.x);
        position.y = clamp(position.y, texCenter.y, PlayfieldHeight-texCenter.y);

        GameBatch.draw(texture, vec4(position.x, position.y, texture.width, texture.height), vec4.init, texCenter);
        GameBatch.flush();
    }
}

Ritta ritta;
void _init() {
    ritta = new Ritta;
}

void _update() {
    kmClearColor(vec4(0, 0, 0, 1));
    ritta.update();
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