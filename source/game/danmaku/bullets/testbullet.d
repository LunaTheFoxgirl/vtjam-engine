module game.danmaku.bullets.testbullet;
import engine;
import config;
import game;

/**
    Player's bullet
*/
class TestBullet : Bullet {
private:

public:
    this(vec2 position, vec2 direction) {
        super(position, direction);
        this.hitRadius = 2;
    }

    override void update() {
        this.rot = atan2(direction.y, direction.x)+radians(90);
        this.position -= (direction*18)*(deltaTime()*SPEED_MULT);
        super.update();
    }
}