module game.danmaku.enemies.bminion;
import engine;
import config;
import game;
import std.random;

private enum MinionSpeed = 0.5*SPEED_MULT;
private enum MinionActionTimeout = 3;
private enum MinionFireTimeout = 2;
private enum MinionMinBullets = 10;
private enum MinionMaxBullets = 40;
private enum BulletFireTimeout = 0.10;

/**
    Minion
*/
class BMinion : Enemy {
private:
    vec2 spawnPosition;

    float minionFireOffset = MinionFireTimeout;
    
    int bulletsToFire;
    float bulletFireOffset = BulletFireTimeout;
    vec2 aimDir;

    static vec2 texSize;
    static vec2 texCenter;


public:
    this() {

        this.health = 50;
        if (!GameAtlas.has("minion")) {
            GameAtlas.add("minion", "assets/sprites/boss0.png");
        }

        texSize = vec2(GameAtlas["minion"].area.z, GameAtlas["minion"].area.w);
        texCenter = vec2(texSize.x/2, texSize.y/2);

        this.position = vec2(
            uniform(64, PlayfieldWidth-64),
            -texSize.y
        );

        this.spawnPosition = this.position;
    }

    override void update() {
        
        // Handle all the hit stuff
        super.update();

        if (bulletsToFire > 0) {
            bulletFireOffset -= deltaTime();
            if (bulletFireOffset <= 0) {
                bulletFireOffset = BulletFireTimeout;

                float angle = atan2(aimDir.y, aimDir.x);
                float randAngle = radians((uniform01()-0.5)*30);

                StageInstance.enemyBullets.spawnBullet(
                    new BasicBullet(
                        position, 
                        vec2(
                            cos(angle-randAngle),
                            sin(angle-randAngle)
                        )
                    )
                );
                
                this.playShootSFX();

                bulletsToFire--;
            }
            return;
        }

        minionFireOffset -= deltaTime();

        if (minionFireOffset <= 0) {
            minionFireOffset = MinionFireTimeout;

            // Sets the state needed to fire a bullet           
            bulletsToFire = cast(float)uniform(MinionMinBullets, MinionMaxBullets);
            aimDir = (this.position-StageInstance.player.position).normalized;
            bulletFireOffset = BulletFireTimeout;
        }

        position = vec2(
            spawnPosition.x+sin(currTime()*5)*10, 
            position.y+(MinionSpeed*deltaTime())
        );
    }

    override void draw() {
        GameBatch.draw(
            GameAtlas["minion"], 
            vec4(position.x, position.y, texSize.x, texSize.y),
            vec4.init,
            texCenter,
            0,
            SpriteFlip.None,
            this.getRenderColor()
        );
        GameBatch.flush();
    }
}