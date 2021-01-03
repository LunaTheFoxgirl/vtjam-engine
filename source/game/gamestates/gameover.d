module game.gamestates.gameover;
import engine;
import game;
import std.format;

class GameOver : GameState {
private:
    bool won;

public:
    this(bool won) {
        this.won = won;
    }

    override void onActivate() {
        kmStopAllMusic();
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
        dstring gameOverString = "GAME OVER%s\n%s"d.format(won ? " (YOU WON!)" : "", getFinalScore());
        vec2 goMeasure = GameFont.measure(gameOverString);
        GameFont.draw(gameOverString, vec2(8, 8));

        GameFont.setSize(kmGetDefaultFontSize());
        GameFont.draw("%s BASE SCORE\n+%s GRAZE COMBO BONUS\nPress ENTER to retry\n\nA game by\n - Luna (@Clipsey5) | Code & Engine\n - 40Nix (@40Nix) | Music and SFX\n - Kusamochi (@Kusamochi_x) | Art\n\nBoss\n - Kitsune Spirit (@Kitsune__Spirit)"d.format(Score, getGrazeBonusScore()), vec2(8, goMeasure.y + 16));

        GameFont.flush();
    }
}