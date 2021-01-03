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
    static Sound shootSFX;
    static Sound deathSFX;

    // Stores last score amount
    long lastScore;

    // Graze multiplier
    int grazeMultiplier;

    Stage stage;
    KeyboardState* state;

    float iFrames = 0;
    float fireCooldown = 0;
    float bombCooldown = 0;
    float grazeCooldown = 0;
    float scoreSubNullifcationCooldown = 0;

    int anim = 0;
    int frame = 0;
    int fTm = 5;
    bool inFocus;

    void updateMovement() {

        inFocus = state.isKeyDown(Key.KeyLeftShift);
        float slowDown = state.isKeyDown(Key.KeyLeftShift) ? PlayerSlowFactor : 1;
        rot = 0;
        

        // Player animation
        anim = 0;
        if (fTm > 0) fTm--;
        if (fTm <= 0) {
            fTm = 5;
            frame = (frame+1)%4;
        }
        

        // Horizontal movement
        if (state.isKeyDown(Key.KeyLeft)) {
            anim = 1;
            rot = radians(345);
            position.x -= (PlayerSpeed/slowDown)*deltaTime();
        }
        if (state.isKeyDown(Key.KeyRight)) {
            anim = 2;
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
            iFrames = PlayerBombCooldown+(PlayerIFrames/2);
            deathSFX.play(GlobalConfig.sfxVolume);
        }
        
        if (bombCooldown > 0) {
            Bullet[] buff = stage.enemyBullets.getBuffer();
            float bombRadius = PlayerBombRadius * bombCooldown;
            foreach(bullet; buff) {

                // Skip nonexistant and dead bullets
                if (bullet is null || !bullet.alive) continue;

                if (position.distance(bullet.position) <= bombRadius+bullet.hitRadius) {
                    bullet.alive = false;
                    shootSFX.play(GlobalConfig.sfxVolume);
                }
            }
        }
    }

    void updateShooting() {
        fireCooldown -= deltaTime();
        if (state.isKeyDown(Key.KeyZ) && fireCooldown < 0) {
            fireCooldown = PlayerBulletCooldown;

            shootSFX.play(GlobalConfig.sfxVolume);

            stage.playerBullets.spawnBullet(new PlayerBullet(vec2(position.x - 4, position.y), vec2(0, 1)));
            stage.playerBullets.spawnBullet(new PlayerBullet(vec2(position.x + 4, position.y), vec2(0, 1)));
            stage.playerBullets.spawnBullet(new PlayerBullet(vec2(position.x - 8, position.y), vec2(0.1, 1)));
            stage.playerBullets.spawnBullet(new PlayerBullet(vec2(position.x + 8, position.y), vec2(-0.1, 1)));
        }
    }

    void updateGraze() {

        // We need these variables to check between state changes of the cooldowns
        float lastGrazeCooldown = grazeCooldown;
        float lastScoreSubNullCooldown = scoreSubNullifcationCooldown;


        if (grazeCooldown >= 0) grazeCooldown -= deltaTime();
        if (scoreSubNullifcationCooldown >= 0) scoreSubNullifcationCooldown -= deltaTime();

        // Handle graze score subtraction cooldown
        if (lastGrazeCooldown >= 0 && grazeCooldown < 0) {
            scoreSubNullifcationCooldown = ScoreSubtractionNullifcationCooldown;
        }

        // If our cooldown has ended, reset lastScore
        // hit uses this to subtract score graze might've given
        // Hence we set it to 0.
        if (lastScoreSubNullCooldown >= 0 && scoreSubNullifcationCooldown < 0) {
            lastScore = 0;
        }

        if (grazeCooldown < 0) {
            Bullet[] buff = stage.enemyBullets.getBuffer();

            foreach(bullet; buff) {

                // Skip nonexistant and dead bullets
                if (bullet is null || !bullet.alive || bullet.hasGrazed) continue;

                if (position.distance(bullet.position) <= PlayerGrazeCircleRadius+bullet.hitRadius) {
                    grazeCooldown = PlayerGrazeCooldown;
                    bullet.hasGrazed = true;
                    statusTextDecay = 3;
                    grazeMultiplier++;
                    if (grazeMultiplier > GrazeBonus) GrazeBonus = grazeMultiplier;
                    this.score(1000);
                    
                    // We don't need to continue the loop nor anything
                    // else if we've already found a bullet that we
                    // can graze against
                    return;
                }
            }
        }
    }

    // TODO: make a text particle system

    float statusTextDecay = 0;
    void drawStatusText() {

        statusTextDecay -= deltaTime();

        // Status strings
        UI.resetTextSize();
        vec2 grazeTextSize = GameFont.measure(GameString_Graze.format(grazeMultiplier));
        GameFont.draw(
            GameString_Graze.format(grazeMultiplier), 
            vec2(position.x-(grazeTextSize.x/2), position.y - 32 - (statusTextDecay < 1 ? 8-(statusTextDecay * 8) : 0)), 
            vec4(1, 1, 1, statusTextDecay)
        );

        GameFont.flush();
    }

    int calcScoreMultiplier() {
        return (grazeMultiplier > 0 ? grazeMultiplier+1 : 2);
    }

public:

    /**
        Constructor
    */
    this(Stage stage) {
        this.stage = stage;

        this.position = vec2(PlayfieldWidth/2, PlayfieldHeight-64);

        if (!GameAtlas.has("player")) {

            // Load player related textures
            GameAtlas.add("player", "assets/sprites/player.png");
            GameAtlas.add("explosion", "assets/sprites/explosion.png");
            GameAtlas.add("grazeCircle", "assets/sprites/graze-circle.png");
            shootSFX = new Sound("assets/sfx/sfx_shoot.ogg");
            deathSFX = new Sound("assets/sfx/sfx_death.ogg");
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
    ubyte bombs = BombCountLimit;

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
        Gets the current damage of the player
    */
    int getDamage() {
        return 10 * (grazeMultiplier > 1 ? 2 : 1);
    }

    /**
        Whether the player is immune to attacks
    */
    bool isInvincible() {
        return iFrames > 0;
    }

    /**
        Adds score
    */
    void score(long score) {
        lastScore = score * calcScoreMultiplier();
        Score += lastScore;
    }

    /**
        Tell player that they've been hit
    */
    void hit() {
        
        // We're invincible while bomb is active
        if (isInvincible()) return;

        // Subtract any score we might've gotten from graze
        Score -= lastScore;
        
        // Reset values that need to be reset
        grazeCooldown = 0;
        grazeMultiplier = 0;
        statusTextDecay = 0;
        lastScore = 0;
        iFrames = PlayerIFrames;

        // Decrease lives
        lives--;

        // TODO: Game Over condition
        if (lives <= 0) {
            deathSFX.play(GlobalConfig.sfxVolume);
            GameStateManager.pop();
            GameStateManager.push(new GameOver(false));
        }
    }

    /**
        Player logic update
    */
    void update() {
        
        // Handle invincibility frames
        if (iFrames > 0) iFrames -= deltaTime();

        state = Keyboard.getState();
        this.updateMovement();
        this.updateItems();
        this.updateBomb();
        this.updateShooting();
        if (!isInvincible) this.updateGraze();
        //this.position = vec2(round(position.x), round(position.y));
    }

    /**
        Player draw
    */
    void draw() {
        if (bombCooldown > 0) {
            float bombSize = 42.0*bombCooldown;

            GameBatch.draw(GameAtlas["explosion"], 
                vec4(position.x, position.y, bombSize, bombSize), 
                vec4.init, 
                vec2(bombSize/2, bombSize/2)
            );
        }


        GameBatch.draw(
            GameAtlas["player"], 
            vec4(position.x, position.y, 32, 32), 
            vec4(
                frame*32,
                anim*32,
                32,
                32
            ), 
            vec2(16, 16), 
            inFocus ? 0 : rot,
            SpriteFlip.None, 
            vec4(1, 1, 1, iFrames > 0 ? 0.5+(1+sin(currTime()*20))/4 : 1)
        );

        enum grazeCirleSize = PlayerGrazeCircleRadius*2;
        GameBatch.draw(
            GameAtlas["grazeCircle"], 
            vec4(position.x, position.y, grazeCirleSize, grazeCirleSize), 
            vec4.init, 
            vec2(PlayerGrazeCircleRadius, PlayerGrazeCircleRadius), 
            0,
            SpriteFlip.None, 
            vec4(1, 1, 1, 0.2)
        );
        GameBatch.flush();

        this.drawStatusText();
    }

    void lateDraw() {
        GameFont.setSize(kmGetDefaultFontSize());
        GameFont.draw(
            "SCORE: %s%s\nBOMBS: %s\nHP: %s\n"d.format(
                Score, 
                lastScore > 0 ? " +%s"d.format(lastScore) : "",
                bombs, 
                lives, 
            ), 
            vec2(8, 8), 
            vec4(1.0, 0, 0, 1)
        );
        GameFont.flush();
    }
}