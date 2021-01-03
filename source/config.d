/*
    Configuration for the game

    The reference for size of viewport is based of the 東方 game series.
*/
module config;

/*
    GENERAL CONFIG
*/

/**
    Speed multiplier
*/
enum SPEED_MULT = 60.0;

enum BaseMusicVolume = 0.5;
enum BaseSFXVolume = 0.5;

/*
    VIEWPORT CONFIGURATION
*/

/**
    Size of a tile
*/
enum TileSizeRatio = 16;

/**
    Amount of tiles in the X axis
*/
enum TileCountX = 24;

/**
    Amount of tiles in the Y axis
*/
enum TileCountY = 28;

/**
    Width of playfield
*/
enum PlayfieldWidth = TileSizeRatio*TileCountX;

/**
    Height of playfield
*/
enum PlayfieldHeight = TileSizeRatio*TileCountY;

/**
    Size of the status sizebar
*/
enum StatusPageWidth = TileSizeRatio*16;


// Ahead-of-time calculations for the viewport based on previous parameters
enum TARGET_WIDTH = PlayfieldWidth+StatusPageWidth;
enum TARGET_HEIGHT = PlayfieldHeight;



/*
    ENEMY CONFIGURATION
*/

/**
    How long the enemy will stay invicible for after getting hit
*/
enum EnemyIFrameTime = 0.2;


/*
    PLAYER CONFIGURATION
*/

/**
    The speed of the player
*/
enum PlayerSpeed = 2*SPEED_MULT;

/**
    Slowdown factor when going slow
*/
enum PlayerSlowFactor = 2;

/**
    How many bombs the player can carry
*/
enum BombCountLimit = 5;

/**
    Second cooldown per bullet fire
*/
enum PlayerBulletCooldown = 0.10;

/**
    Second cooldown per grace event
*/
enum PlayerGrazeCooldown = 5;

/**
    How long the player is invincible for after getting hit
*/
enum PlayerIFrames = 2;

/**
    Cooldown before bomb dissapates
*/
enum PlayerBombCooldown = 5;

/**
    Radius of bomb explosion
*/
enum PlayerBombRadius = 24.0;

/**
    Distance from player center that bullets can collide with
*/
enum PlayerHitCircleRadius = 2.0;

/**
    Distance from the player center that graze can happen
*/
enum PlayerGrazeCircleRadius = 10.0;





/*
    SCORING
*/

/**
    Amount you score for grazing
*/
enum GrazeScoreAmount = 1000;

/**
    Amount you score for defeating an enemy
*/
enum EnemyDeathScoreAmount = 10_000;

/**
    Amount you score for killing a boss
*/
enum BossDeathScoreAmount = 1_000_000;

/**
    Score multiplier that gets applied to the player
    during a graze
*/
enum GrazeScoreMultiplier = 2;

/**
    How many seconds after a graze and other multiplier events
    that score can be nullified
*/
enum ScoreSubtractionNullifcationCooldown = 5;

/**
    After the fact bonus score
*/
enum GrazeBonusScore = 100_000;