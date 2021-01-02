module game.danmaku.stage;
import engine;
import game;
import config;
import std.random;

class StageMusicManager {
private:
    Music[] tracks;
    size_t currentTrack;

public:
    this(Music[] tracks) {
        this.tracks = tracks;

        // So the first call of nextTrack is always the first track
        this.currentTrack = tracks.length-1;
    }

    /**
        Moves to next track
    */
    void nextTrack() {
        tracks[currentTrack].stop();
        currentTrack++;
        currentTrack %= tracks.length;

        tracks[currentTrack].setLooping(true);
        tracks[currentTrack].play(BaseMusicVolume);
    }
}

/**
    Global instance of the map
*/
Stage StageInstance;

/**
    The map
*/
class Stage {
private:
    StageMusicManager musicManager;

public:
    /**
        The bullet buffer for enemies
    */
    BulletBuffer!(2000) enemyBullets;

    /**
        The bullet buffer for the player
    */
    BulletBuffer!(500) playerBullets;

    /**
        The player
    */
    Player player;

    /**
        Constructor
    */
    this() {
        StageInstance = this;

        initBulletTexture();
        player = new Player(this);

        // Instantiate the bullet buffers (they're classes, since we want this on the heap)
        enemyBullets = new BulletBuffer!(2000);
        playerBullets = new BulletBuffer!(500);

        musicManager = new StageMusicManager([new Music("assets/bgm/bgm1.ogg")]);
        musicManager.nextTrack();
    }

    int testCooldown = 1;
    /**
        Updates the map
    */
    void update() {
        player.update();

        testCooldown--;
        if (testCooldown <= 0) {
            testCooldown = 2;

            enemyBullets.spawnBullet(new TestBullet(vec2(
                uniform(0, PlayfieldWidth),
                0
            ),
            vec2(
                0,
                -0.05
            )));
        }

        // Note: We want enemy bullets to deal damage to the player
        // before the player can deal damage to the enemy
        enemyBullets.update();
        playerBullets.update();
    }

    /**
        Draws the map
    */
    void draw() {

        // NOTE: We want these to appear under the enemy bullets, 
        // hence we draw them first
        playerBullets.draw();

        // Player draws ontop of bullets
        player.draw();

        // And finally enemy bullets draw ontop of player
        enemyBullets.draw();

        // TODO: make proper UI
        player.lateDraw();
    }
}