module game.danmaku.enemies.bosskitsu;
import engine;
import config;
import game;
import std.random;

private enum BossSpeed = 0.5*SPEED_MULT;
private enum BossActionTimeout = 3;
private enum BossFireTimeout = 2;
private enum BossMinBullets = 10;
private enum BossMaxBullets = 40;
private enum BulletFireTimeout = 0.10;
private enum FireModes = 3;

private enum BulletFireTimeoutMode1 = 0.8;
private enum BossMinBulletsMode1 = 20;
private enum BossMaxBulletsMode1 = 40;

/**
    Boss (Kitsune Spirit)
*/
class BossKitsu : Enemy {
private:
    static vec2 texSize;
    static vec2 texCenter;

    vec2 targetPosition;

    float minionFireOffset = BossFireTimeout;
    
    int bulletsToFire;
    float bulletFireOffset = BulletFireTimeout;
    vec2 aimDir;


    int fireMode = 0;

public:
    this() {
        this.isBoss = true;
        this.health = 10_000;

        if (!GameAtlas.has("boss")) {
            GameAtlas.add("boss", "assets/sprites/boss0.png");
        }

        texSize = vec2(GameAtlas["boss"].area.z, GameAtlas["boss"].area.w);
        texCenter = vec2(texSize.x/2, texSize.y/2);

        this.position = vec2(
            PlayfieldWidth/2,
            -64
        );

        this.targetPosition = vec2(
            PlayfieldWidth/2,
            64
        );

        MusicManager.play("boss");
    }

    override void update() {
        
        // Handle all the hit stuff
        super.update();

        switch(fireMode) {
            case 0:
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
                break;
            case 1:
                if (bulletsToFire > 0) {
                    bulletFireOffset -= deltaTime();
                    if (bulletFireOffset <= 0) {
                        bulletFireOffset = BulletFireTimeoutMode1;

                        // Calculates which angles the bullets need to be spawned at to form a circle            
                        float bulletCount = cast(float)uniform(BossMinBulletsMode1, BossMaxBulletsMode1);
                        float rotDist = radians(360/bulletCount);

                        // Spawns bullets aiming in a circle out
                        foreach(i; 0..bulletCount) {
                            StageInstance.enemyBullets.spawnBullet(
                                new WaveBullet(
                                    position, 
                                    (cast(float)i*rotDist),
                                    bulletsToFire%2 == 0
                                )
                            );
                        }

                        this.playShootSFX();

                        bulletsToFire--;
                    }
                    
                    return;
                }
                
                break;

            case 2:
                this.targetPosition = vec2(
                    uniform(8, PlayfieldWidth-8),
                    uniform(32, 128),
                );
                minionFireOffset = 0;
                break;
            default: assert(0);
        }

        minionFireOffset -= deltaTime();

        if (minionFireOffset <= 0) {
            minionFireOffset = BossFireTimeout;

            // Sets the state needed to fire a bullet           
            bulletsToFire = cast(float)uniform(BossMinBullets, BossMaxBullets);
            aimDir = (this.position-StageInstance.player.position).normalized;
            bulletFireOffset = BulletFireTimeout;

            // NOTE: Maybe chose randomly?
            fireMode = (fireMode+1)%FireModes; // = uniform(0, FireModes);

            // Special case: we only wanna fire 8 volleys of these
            if (fireMode == 1) bulletsToFire = 8;
        }

        position = dampen(position, targetPosition, deltaTime(), 1);
    }

    override void draw() {
        GameBatch.draw(
            GameAtlas["boss"], 
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