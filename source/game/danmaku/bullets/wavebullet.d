module game.danmaku.bullets.wavebullet;
import engine;
import config;
import game;

/**
    Wave bullet
*/
class WaveBullet : Bullet {
private:
    vec2 startPos;
    bool clockwise;
    float offset;
    float angle;
    float size = 16;

public:
    this(vec2 position, float angle, bool clockwise) {
        super(position, vec2(0, 0));
        this.hitRadius = 6;
        this.startPos = position;
        this.clockwise = clockwise;
        this.offset = 0;
        this.angle = angle;
    }

    override void update() {

        // Handle sprite rotation and offset
        this.rot = atan2(direction.y, direction.x)+radians(90);
        this.offset += (1*SPEED_MULT)*deltaTime();

        // Handle world rotation
        if (clockwise) {
            angle += radians((0.25*SPEED_MULT)*deltaTime());
        } else {
            angle -= radians((0.25*SPEED_MULT)*deltaTime());
        }

        // Handle translating to position
        this.position = startPos+(vec2(
            sin(angle),
            cos(angle)
        )*offset);

        size += deltaTime();
        this.hitRadius = (size/2)-2;

        super.update();
    }

    override void draw() {
        GameBatch.draw(GameAtlas["bullets"], vec4(position.x, position.y, size, size), vec4(16, 0, 16, 16), vec2(8, 8), rot);
    }
}