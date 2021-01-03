module game.danmaku.bullet;
import game.danmaku.bullet;
import engine;
import config;
import game;

/**
    A buffer of bullets
*/
class BulletBuffer(size_t size) {
private:
    Bullet[size] buffer;

public:

    /**
        Gets the underlying buffer
    */
    ref Bullet[size] getBuffer() {
        return buffer;
    }

    /**
        Spawns bullet at the specified position

        Returns true if successful
        Returns false if buffer is full
    */
    bool spawnBullet(Bullet bullet) {
        foreach(i; 0..size) {
            if (buffer[i] is null || !buffer[i].alive) {
                buffer[i] = bullet;
                return true;
            }
        }
        return false;
    }

    /**
        Updates the buffer's elements
    */
    void update() {
        foreach(i; 0..buffer.length) {

            // Skip bullets that are disabled
            if (buffer[i] is null || !buffer[i].alive) continue;

            buffer[i].update();
        }
    }

    /**
        Draws the buffer's elements
    */
    void draw() {
        foreach(i; 0..buffer.length) {

            // Skip bullets that are disabled
            if (buffer[i] is null || !buffer[i].alive) continue;

            buffer[i].draw();
        }
        GameBatch.flush();
    }
}

/**
    A bullet
*/
abstract class Bullet {
public:
    /**
        Spawns bullet at position
    */
    this(vec2 position, vec2 direction = vec2(0, 1)) {
        this.position = position;
        this.direction = direction;
        this.alive = true;
        this.hitRadius = 4;
    }

    /**
        Whether the bullet is a player bullet
    */
    bool isPlayerBullet;
    
    /**
        This bullet's hit circle
    */
    float hitRadius;

    /**
        Whether the bullet is "alive"
        In other words should be updated and drawn
    */
    bool alive;

    /**
        Whether the bullet has been grazed against
    */
    bool hasGrazed;

    /**
        Position of bullet
    */
    vec2 position;

    /**
        Direction unit vector
    */
    vec2 direction;

    /**
        Rotation of bullet sprite
    */
    float rot = 0;

    /**
        Update the bullet
    */
    void update() {
        //this.position = vec2(round(position.x), round(position.y));

        // Kill bullet if outside play area (and somewhat invisible)
        // 4 pixels added for good measure
        float size = (hitRadius*2)+4;
        if (position.x < -size || position.x > PlayfieldWidth+size ||
            position.y < -size || position.y > PlayfieldHeight+size) alive = false;

        // Handle damaging the player if we're not a player bullet
        if (!isPlayerBullet && this.collidesWithPlayer() && !StageInstance.player.isInvincible()) {
            StageInstance.player.hit();
            this.alive = false;
        }
    }

    /**
        Gets whether this bullet is colliding with the player
    */
    bool collidesWithPlayer() {
        return position.distance(StageInstance.player.position) <= PlayerHitCircleRadius+hitRadius;
    }

    /**
        Draw the bullet
    */
    abstract void draw();
}

void initBulletTexture() {
    if (!GameAtlas.has("bullets")) {
        GameAtlas.add("bullets", "assets/sprites/shitty_bullets.png");
    }
}