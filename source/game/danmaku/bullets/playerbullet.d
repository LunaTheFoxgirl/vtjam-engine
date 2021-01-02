module game.danmaku.bullets.playerbullet;
import engine;
import config;
import game;

/**
    Player's bullet
*/
class PlayerBullet : Bullet {
private:

public:
    this(vec2 position, vec2 direction) {
        super(position, direction);
        this.isPlayerBullet = true;
    }

    override void update() {
        this.rot = atan2(direction.y, direction.x)+radians(90);
        this.position -= (direction*12)*(deltaTime()*SPEED_MULT);
        super.update();
    }
}