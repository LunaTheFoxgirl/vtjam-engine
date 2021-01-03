module game.gamestates.gameover;
import engine;
import game;
import std.format;

class GameOver : GameState {
public:

    override void onActivate() {
    }

    override void update() {
        if (Keyboard.getState().isKeyDown(Key.KeyReturn)) {
            GameStateManager.pop();
            GameStateManager.push(new InGameState());

            // Reset score after restarting game
            gameResetScore();
        }
    }

    override void draw() {
        GameFont.setSize(kmGetDefaultFontSize()*2);
        dstring gameOverString = "GAME OVER\n%s"d.format(getFinalScore());
        vec2 goMeasure = GameFont.measure(gameOverString);
        GameFont.draw(gameOverString, vec2(8, 8));

        GameFont.setSize(kmGetDefaultFontSize());
        GameFont.draw("%s BASE SCORE\n+%s GRAZE COMBO BONUS\nPress ENTER to retry"d.format(Score, getGrazeBonusScore()), vec2(8, goMeasure.y + 8));

        GameFont.flush();
    }
}