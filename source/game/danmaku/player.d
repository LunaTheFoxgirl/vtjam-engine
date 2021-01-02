module game.danmaku.player;
import engine;
import game;
import config;
import std.format;

/**
    The player
*/
class Player {
private:

    Stage stage;
    KeyboardState* state;
    AtlasIndex playerSprite;

    float fireCooldown = 0;
    float bombCooldown = 0;

    void updateMovement() {

        float slowDown = state.isKeyDown(Key.KeyLeftShift) ? PlayerSlowFactor : 1;
        rot = 0;
        

        // Horizontal movement
        if (state.isKeyDown(Key.KeyLeft)) {
            rot = radians(345);
            position.x -= (PlayerSpeed/slowDown)*deltaTime();
        }
        if (state.isKeyDown(Key.KeyRight)) {
            rot = radians(15);
            position.x += (PlayerSpeed/slowDown)*deltaTime();
        }
        
        // Vertical movement
        if (state.isKeyDown(Key.KeyUp)) position.y -= (PlayerSpeed/slowDown)*deltaTime();
        if (state.isKeyDown(Key.KeyDown)) position.y += (PlayerSpeed/slowDown)*deltaTime();

        this.position.x = clamp(this.position.x, 0, PlayfieldWidth);
        this.position.y = clamp(this.position.y, 0, PlayfieldHeight);
    }

    void updateItems() {

        // We can't have more bombs than our count limit
        if (bombs > BombCountLimit) bombs = BombCountLimit;
    }

    void updateBomb() {
        bombCooldown -= deltaTime();
        if (state.isKeyDown(Key.KeyX) && bombCooldown < 0 && bombs > 0) {
            bombs--;
            bombCooldown = PlayerBombCooldown;
        }
        
        if (bombCooldown > 0) {
            Bullet[] buff = stage.enemyBullets.getBuffer();
            float bombRadius = PlayerBombRadius * bombCooldown;
            foreach(bullet; buff) {

                // Skip nonexistant and dead bullets
                if (bullet is null || !bullet.alive) continue;

                if (position.distance(bullet.position) <= bombRadius+bullet.hitRadius) {
                    bullet.alive = false;
                }
            }
        }
    }

    void updateShooting() {
        fireCooldown -= deltaTime();
        if (state.isKeyDown(Key.KeyZ) && fireCooldown < 0) {
            fireCooldown = PlayerBulletCooldown;

            stage.playerBullets.spawnBullet(new PlayerBullet(vec2(position.x - 4, position.y), vec2(0, 1)));
            stage.playerBullets.spawnBullet(new PlayerBullet(vec2(position.x + 4, position.y), vec2(0, 1)));
            stage.playerBullets.spawnBullet(new PlayerBullet(vec2(position.x - 8, position.y), vec2(0.1, 1)));
            stage.playerBullets.spawnBullet(new PlayerBullet(vec2(position.x + 8, position.y), vec2(-0.1, 1)));
        }
    }

public:

    /**
        Constructor
    */
    this(Stage stage) {
        this.stage = stage;

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
    ubyte bombs = 1;

    /**
        The player's position on the screen
    */
    vec2 position;

    /**
        Rotation
    */
    float rot = 0;

    /**
        How many lives the player has left
    */
    int lives = 10;

    /**
        Whether the player is immune to attacks
    */
    bool isImmune() {
        return bombCooldown > 0;
    }

    /**
        Tell player that they've been hit
    */
    void hit() {
        
        // We're invincible while bomb is active
        if (bombCooldown > 0) return;

        // Decrease lives
        lives--;

        // TODO: Game Over condition
        if (lives <= 0) {

        }
    }

    /**
        Player logic update
    */
    void update() {
        state = Keyboard.getState();
        this.updateMovement();
        this.updateItems();
        this.updateBomb();
        this.updateShooting();
        //this.position = vec2(round(position.x), round(position.y));
    }

    /**
        Player draw
    */
    void draw() {
        GameBatch.draw(playerSprite, vec4(position.x, position.y, 32, 32), vec4.init, vec2(16, 16), rot);
        GameBatch.flush();
    }

    void lateDraw() {
        GameFont.setSize(kmGetDefaultFontSize()*2);
        GameFont.draw("HP: %s\nBOMBS: %s"d.format(lives, bombs), vec2(8, 8), vec4(1.0, 0, 0, 1));
        GameFont.flush();
    }
}