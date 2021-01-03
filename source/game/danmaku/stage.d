module game.danmaku.stage;
import engine;
import game;
import config;
import std.random;
/**
    Music manager for stage
*/
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
        tracks[currentTrack].play(GlobalConfig.musicVolume);
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
        Director of enemies
    */
    EnemyDirector enemyDirector;

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
        gameLoadStrings();
        player = new Player(this);

        // Instantiate the bullet buffers (they're classes, since we want this on the heap)
        enemyBullets = new BulletBuffer!(2000);
        playerBullets = new BulletBuffer!(500);
        enemyDirector = new EnemyDirector(
            [
                WaveInfo(
                    [
                        SpawnInfo("bminion", 4),
                        SpawnInfo("aminion", 10)
                    ],
                    SpawnMode.Multiple,
                    2
                ),
                WaveInfo(
                    [
                        SpawnInfo("bminion", 10),
                        SpawnInfo("bminion", 10),
                    ],
                    SpawnMode.Multiple,
                    3
                ),
                WaveInfo(
                    [
                        SpawnInfo("bminion", 10),
                        SpawnInfo("bminion", 10),
                        SpawnInfo("aminion", 10),
                        SpawnInfo("aminion", 10),
                    ],
                    SpawnMode.Multiple,
                    4
                )
            ]
        );

        musicManager = new StageMusicManager([new Music("assets/bgm/bgm1.ogg")]);
        musicManager.nextTrack();
    }

    /**
        Updates the map
    */
    void update() {
        player.update();

        // Note: We want enemy bullets to deal damage to the player
        // before the player can deal damage to the enemy
        enemyBullets.update();
        playerBullets.update();
        enemyDirector.update();
    }

    /**
        Draws the map
    */
    void draw() {

        // NOTE: We want bullets to appear underneath enemies and player
        // Hence we draw them first
        playerBullets.draw();
        enemyBullets.draw();

        // Player draws ontop of bullets
        player.draw();

        // Draw enemies over bullets
        enemyDirector.draw();

        // TODO: make proper UI
        player.lateDraw();
    }
}