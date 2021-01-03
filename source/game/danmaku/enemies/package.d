module game.danmaku.enemies;
import game.danmaku.enemy;
public import game.danmaku.enemies.aminion;
public import game.danmaku.enemies.bminion;
public import game.danmaku.enemies.bosskitsu;

shared static this() {
    gameAddEnemyFactory("aminion", () { return cast(Enemy)new AMinion(); });
    gameAddEnemyFactory("bminion", () { return cast(Enemy)new BMinion(); });
    gameAddEnemyFactory("boss", () { return cast(Enemy)new BossKitsu(); });
}