module game.gamestates.ingame;
import engine;
import game;
import std.format;

class InGameState : GameState {
private:
    Stage stage;

public:

    override void onActivate() {
        stage = new Stage();
    }

    override void update() {
        stage.update();
    }

    override void draw() {
        kmClearColor(vec4(0.2, 0.2, 0.2, 1));
        stage.draw();
    }
}