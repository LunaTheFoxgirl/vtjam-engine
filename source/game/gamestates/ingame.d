module game.gamestates.ingame;
import engine;
import game;
import std.format;

class InGameState : GameState {
private:
    Map map;

public:

    override void onActivate() {
        map = new Map();
    }

    override void update() {
        map.update();
    }

    override void draw() {
        kmClearColor(vec4(0.7, 0.7, 0.7, 1));
        map.draw();
    }
}