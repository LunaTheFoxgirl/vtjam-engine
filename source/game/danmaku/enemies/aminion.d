module game.danmaku.enemies.aminion;
import engine;
import config;
import game;
import std.random;

private enum MinionActionTimeout = 3;
private enum MinionFireTimeout = 2;
private enum MinionMinBullets = 10;
private enum MinionMaxBullets = 40;
private enum MinionFrames = 4;

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

    float fTm = 5;
    int frame = 0;
    void updateAnimation() {
        if (fTm > 0) fTm--;
        if (fTm <= 0) {
            fTm = 5;
            frame = (frame+1)%MinionFrames;
        }
    }

public:
    this() {
        this.health = 50;

        if (!GameAtlas.has("miniona")) {
            GameAtlas.add("miniona", "assets/sprites/miniona.png");
            texSize = vec2(GameAtlas["miniona"].area.z/MinionFrames, GameAtlas["miniona"].area.w);
            texCenter = vec2(texSize.x/2, texSize.y/2);
        }
        
        this.position = vec2(
            uniform(texSize.x, PlayfieldWidth-texSize.x),
            -texSize.y
        );
    }

    override void update() {
        
        // Handle all the hit stuff
        super.update();

        this.updateAnimation();

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
            GameAtlas["miniona"], 
            vec4(position.x, position.y, texSize.x, texSize.y),
            vec4(frame*texSize.x, 0, texSize.x, texSize.y),
            texCenter,
            0,
            SpriteFlip.None,
            this.getRenderColor()
        );
        GameBatch.flush();
    }
}