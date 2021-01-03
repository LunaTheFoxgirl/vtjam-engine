module game.danmaku.enemies.aminion;
import engine;
import config;
import game;
import std.random;

private enum MinionActionTimeout = 3;
private enum MinionFireTimeout = 2;
private enum MinionMinBullets = 10;
private enum MinionMaxBullets = 40;

/**
    Minion
*/
class AMinion : Enemy {
private:
    float minionActionOffset = MinionActionTimeout;
    float minionFireOffset = MinionFireTimeout;
    vec2 targetPosition;

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
            uniform(texSize.x, PlayfieldWidth-texSize.x),
            -texSize.y
        );
    }

    override void update() {
        
        // Handle all the hit stuff
        super.update();

        minionFireOffset -= deltaTime();
        minionActionOffset -= deltaTime();

        if (minionFireOffset <= 0) {
            minionFireOffset = MinionFireTimeout;

            // Calculates which angles the bullets need to be spawned at to form a circle            
            float bulletCount = cast(float)uniform(MinionMinBullets, MinionMaxBullets);
            float rotDist = radians(360/bulletCount);

            // Spawns bullets aiming in a circle out
            foreach(i; 0..bulletCount) {
                StageInstance.enemyBullets.spawnBullet(
                    new BasicBullet(
                        position, 
                        vec2(
                            cos(rotDist*cast(float)i),
                            sin(rotDist*cast(float)i)
                        )
                    )
                );
            }
            
            this.playShootSFX();
        }

        if (position.y < 0) {
            targetPosition = vec2(position.x, 32);
        } else if (minionActionOffset <= 0) {
            minionActionOffset = MinionActionTimeout;

            targetPosition = position+vec2(
                uniform(-64, 64),
                uniform(-2, 128)
            );

            targetPosition.x = clamp(targetPosition.x, 8, PlayfieldWidth-8);
            targetPosition.y = clamp(targetPosition.y, 8, PlayfieldHeight*2);
        }
        position = dampen(position, targetPosition, deltaTime(), 1);
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