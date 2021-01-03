module game.danmaku.enemy;
import engine;
import config;
import game;
import containers.list;

/**
    Enemy Director handles spawning enemies on screen
*/
class EnemyDirector {
private:

    List!Enemy enemies;

    WaveInfo[] waveInfo;
    size_t spawnEntry;

    float spawnOffset = 0;
    bool couldSpawn;

    /**
        Handle spawning
    */
    void handleSpawn() {
        if (spawnOffset >= 0) spawnOffset -= deltaTime();
        
        // When we have to handle spawn
        if (spawnOffset <= 0 && spawnEntry < waveInfo.length) {

            // Reset cooldown
            spawnOffset = waveInfo[spawnEntry].spawnCooldown;

            int spawned = 0;

            switch(waveInfo[spawnEntry].mode) {
                case SpawnMode.Sequential:
                    foreach(i; 0..waveInfo[spawnEntry].enemiesToSpawn.length) {
                        if (waveInfo[spawnEntry].enemiesToSpawn[i].count > 0) {
                            waveInfo[spawnEntry].enemiesToSpawn[i].count--;
                            this.enemies.add(
                                gameCreateEnemy(waveInfo[spawnEntry].enemiesToSpawn[i].enemyName)
                            );
                            spawned++;
                            break;
                        }
                    }
                    break;

                case SpawnMode.Multiple:
                    foreach(i; 0..waveInfo[spawnEntry].enemiesToSpawn.length) {
                        if (waveInfo[spawnEntry].enemiesToSpawn[i].count > 0) {
                            waveInfo[spawnEntry].enemiesToSpawn[i].count--;

                            this.enemies.add(
                                gameCreateEnemy(waveInfo[spawnEntry].enemiesToSpawn[i].enemyName)
                            );
                            spawned++;
                        }
                    }
                    break;

                default: assert(0);
            }

            // Store whether something could be spawned or not
            couldSpawn = spawned > 0;

        } else if (enemies.count == 0) {
            
            if(!couldSpawn) next();

            if (spawnEntry >= waveInfo.length) {
                // Handle win conditon: All enemies exhausted
                GameStateManager.pop();
                GameStateManager.push(new GameOver);
            }
        }
    }

    /**
        Move to next entry
    */
    void next() {
        spawnEntry++;
        spawnOffset = 0;

        // Handle win conditon: All enemies exhausted
        if (spawnEntry >= waveInfo.length && enemies.count == 0) {
            GameStateManager.pop();
            GameStateManager.push(new GameOver);
        }
    }

public:
    this(WaveInfo[] waveInfo) {
        this.waveInfo = waveInfo;
    }

    /**
        Updates all enemies in the director
    */
    void update() {

        // Handle spawning enemies
        this.handleSpawn();

        // Update enemies and get a list of enemies to collect
        size_t[] toCollect;
        foreach(i, enemy; enemies) {
            enemy.update();
            
            // Mark dead enemies for collection
            if (!enemy.alive) {
                toCollect ~= i;
                continue;
            }
        }

        // Collect any dead enemies
        foreach(i; toCollect) {
            enemies.removeAt(i);
        }
    }

    /**
        Updates all enemies in the director
    */
    void draw() {
        foreach(enemy; enemies) {
            enemy.draw();
        }

        // Make sure last enemy is flushed
        GameBatch.flush();
    }
}

alias EnemyFactoryFunc = Enemy delegate();
private EnemyFactoryFunc[string] factories;

/*
    Add enemy factory
*/
void gameAddEnemyFactory(string name, EnemyFactoryFunc fact) {
    factories[name] = fact;
}

/**
    Creates a new enemy from the factory
*/
Enemy gameCreateEnemy(string name) {
    return factories[name]();
}

/**
    An enemy base class
*/
abstract class Enemy {
private:
    float iFrames = 0;
    static Sound damageSFX;
    static Sound killSFX;
    static Sound shootSFX;

protected:
    void handlePlayerHit() {
        if (iFrames > 0) {
            iFrames -= deltaTime();
            return;
        }
        

        // Check for any player bullet collissions
        foreach(bullet; StageInstance.playerBullets.getBuffer()) {
            if (bullet !is null && bullet.alive) {

                // Collission happened
                if (bullet.position.distance(position) <= this.hitRadius+bullet.hitRadius) {
                    
                    // Kill bullet
                    bullet.alive = false;

                    // Damage ourselves
                    this.health -= StageInstance.player.getDamage();

                    iFrames = EnemyIFrameTime;

                    damageSFX.play(GlobalConfig.sfxVolume);
                }
            }
        }
    }

    vec4 getRenderColor() {
        return vec4(1, 1, 1, iFrames > 0 ? 0.5+(1+sin(currTime()*20))/4 : 1);
    }

    void playShootSFX() {
        shootSFX.play(GlobalConfig.sfxVolume);
    }

public:
    /**
        Construct enemy
    */
    this() {
        if (damageSFX is null) {
            damageSFX = new Sound("assets/sfx/sfx_damage.ogg");
            killSFX = new Sound("assets/sfx/sfx_kill.ogg");
            shootSFX = new Sound("assets/sfx/sfx_shoot.ogg");
        }
    }

    /**
        Position of enemy
    */
    vec2 position;

    /**
        Whether the enemy is a boss
    */
    bool isBoss;

    /**
        Whether the enemy is alive
    */
    bool alive = true;

    /**
        Health of enemy
    */
    int health;

    /**
        Hit radius of this enemy
    */
    float hitRadius = 8;

    /**
        Updates the enemy
    */
    void update() {

        // Handle taking damage from player
        this.handlePlayerHit();

        // If they go offscreen on bottom or sides they despawn
        // They won't award points for that
        if (position.y > PlayfieldHeight+hitRadius+4 || 
            position.x < -hitRadius+4 || 
            position.x > PlayfieldWidth+hitRadius+4) {
            
            alive = false;
        }

        // If we're out of health kill this enemy
        if (health < 0 && alive) {
            alive = false;

            killSFX.play(GlobalConfig.sfxVolume);

            // Give player score
            if (!isBoss) StageInstance.player.score(EnemyDeathScoreAmount);
            else StageInstance.player.score(BossDeathScoreAmount);
        }
    }

    /**
        Draws the enemy
    */
    abstract void draw();
}