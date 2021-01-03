module game.danmaku.bullets.basicbullet;
import engine;
import config;
import game;

/**
    Player's bullet
*/
class BasicBullet : Bullet {
private:

public:
    this(vec2 position, vec2 direction) {
        super(position, direction);
        this.hitRadius = 8;
    }

    override void update() {
        this.rot = atan2(direction.y, direction.x)+radians(90);
        this.position -= (direction*(1*SPEED_MULT))*deltaTime();
        super.update();
    }

    override void draw() {
        GameBatch.draw(GameAtlas["bullets"], vec4(position.x, position.y, 16, 16), vec4(16, 0, 16, 16), vec2(8, 8), rot);
    }
}