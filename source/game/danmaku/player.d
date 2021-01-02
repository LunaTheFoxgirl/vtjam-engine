module game.danmaku.player;
import engine;
import game;
import config;

/**
    The player
*/
class Player {
private:
    KeyboardState* state;
    AtlasIndex playerSprite;

    void updateMovement() {

        // Horizontal movement
        if (state.isKeyDown(Key.KeyLeft)) position.x -= deltaTime()*PlayerSpeed;
        if (state.isKeyDown(Key.KeyRight)) position.x += deltaTime()*PlayerSpeed;
        
        // Vertical movement
        if (state.isKeyDown(Key.KeyUp)) position.y -= deltaTime()*PlayerSpeed;
        if (state.isKeyDown(Key.KeyDown)) position.y += deltaTime()*PlayerSpeed;

        this.position.x = clamp(this.position.x, 0, PlayfieldWidth);
        this.position.y = clamp(this.position.y, 0, PlayfieldHeight);
    }

    void updateItems() {

        // We can't have more bombs than our count limit
        if (bombs > BombCountLimit) bombs = BombCountLimit;
    }

    void updateShooting() {

    }

public:

    /**
        Constructor
    */
    this() {

        if (!GameAtlas.has("player")) {
            // Load player texture
            GameAtlas.add("player", "assets/sprites/player.png");
            playerSprite = GameAtlas["player"];
        }
    }

    /**
        The player's damage multiplier
    */
    int damageMultiplier;

    /**
        Player's bomb count, can max have 255 bombs
        (this will be soft limited to BombCountLimit)
    */
    ubyte bombs;

    /**
        The player's position on the screen
    */
    vec2 position;

    /**
        How many lives the player has left
    */
    int lives;

    /**
        Player logic update
    */
    void update() {
        state = Keyboard.getState();
        this.updateMovement();
        this.updateItems();
        this.updateShooting();
    }

    /**
        Player draw
    */
    void draw() {
        GameBatch.draw(playerSprite, vec4(position.x, position.y, 32, 32), vec4.init, vec2(16, 16), 0);
        GameBatch.flush();
    }
}