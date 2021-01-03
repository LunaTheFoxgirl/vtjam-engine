module game.danmaku.score;
import config;

/**
    The current score
*/
long Score;

/**
    Graze bonus
*/
long GrazeBonus;

/**
    Resets the score
*/
void gameResetScore() {
    Score = 0;
    GrazeBonus = 0;
}

long getGrazeBonusScore() {
    return GrazeBonusScore*GrazeBonus;
}

long getFinalScore() {
    return Score + getGrazeBonusScore();
}
