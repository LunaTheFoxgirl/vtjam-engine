module game.danmaku.map;
import engine;
import game;
import config;

class MapMusicManager {
private:
    Music[] tracks;
    size_t currentTrack;

public:
    this(Music[] tracks) {
        this.tracks = tracks;

        // So the first call of nextTrack is always the first track
        this.currentTrack = tracks.length-1;
    }

    /**
        Moves to next track
    */
    void nextTrack() {
        tracks[currentTrack].stop();
        currentTrack++;
        currentTrack %= tracks.length;

        tracks[currentTrack].setLooping(true);
        tracks[currentTrack].play(BaseMusicVolume);
    }
}

/**
    The map
*/
class Map {
private:
    MapMusicManager musicManager;

public:
    /**
        The player
    */
    Player player;

    /**
        Constructor
    */
    this() {
        player = new Player();

        musicManager = new MapMusicManager([new Music("assets/bgm/bgm1.ogg")]);
        musicManager.nextTrack();
    }

    /**
        Updates the map
    */
    void update() {
        player.update();
    }

    /**
        Draws the map
    */
    void draw() {
        player.draw();
    }
}