module game.danmaku.data;

/**
    Spawning mode
*/
enum SpawnMode : string {
    Sequential = "sequential",
    Multiple = "multi"
}

/**
    Enemy spawn info
*/
struct WaveInfo {
    
    /**
        Enemies to spawn
    */
    SpawnInfo[] enemiesToSpawn;
    
    /**
        Should the spawner choose a random enemy to spawn
    */
    SpawnMode mode;

    /**
        How long to wait between each enemy spawn
    */
    float spawnCooldown = 2;
}

/**
    Enemy spawn info
*/
struct SpawnInfo {
    /**
        Enemy to spawn
    */
    string enemyName;

    /**
        How many to spawn
    */
    int count;
}