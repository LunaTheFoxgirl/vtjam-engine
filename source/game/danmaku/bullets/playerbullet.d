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
        this.hitRadius = 4;
    }

    override void update() {
        this.rot = atan2(direction.y, direction.x)+radians(90);
        this.position -= (direction*12)*(deltaTime()*SPEED_MULT);
        super.update();
    }

    override void draw() {
        GameBatch.draw(GameAtlas["playerbullets"], vec4(position.x, position.y, 8, 8), vec4(0, 0, 8, 8), vec2(8, 8), rot);
    }
}