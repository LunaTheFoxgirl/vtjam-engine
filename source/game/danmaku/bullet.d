module game.danmaku.bullet;
import engine;

/**
    A bullet
*/
struct Bullet {

    /**
        ID of the sprite to apply to the bullet
        Will be centered on bullet
    */
    int bulletSpriteId;

    /**
        Whether the bullet is "alive"
        In other words should be updated and drawn
    */
    bool alive;

    /**
        Whether the bullet belongs to the player
    */
    bool isPlayerBullet;

    /**
        Position of bullet
    */
    vec2i position;
}