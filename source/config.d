/*
    Configuration for the game

    The reference for size of viewport is based of the 東方 game series.
*/
module config;

/*
    GENERAL CONFIG
*/

enum BaseMusicVolume = 0.5;
enum BaseSFXVolume = 0.5;

/*
    VIEWPORT CONFIGURATION
*/

/**
    Size of a tile
*/
enum TileSizeRatio = 16;

/**
    Amount of tiles in the X axis
*/
enum TileCountX = 24;

/**
    Amount of tiles in the Y axis
*/
enum TileCountY = 28;

/**
    Width of playfield
*/
enum PlayfieldWidth = TileSizeRatio*TileCountX;

/**
    Height of playfield
*/
enum PlayfieldHeight = TileSizeRatio*TileCountY;

/**
    Size of the status sizebar
*/
enum StatusPageWidth = TileSizeRatio*16;


// Ahead-of-time calculations for the viewport based on previous parameters
enum TARGET_WIDTH = PlayfieldWidth+StatusPageWidth;
enum TARGET_HEIGHT = PlayfieldHeight;





/*
    PLAYER CONFIGURATION
*/


/**
    The speed of the player
*/
enum PlayerSpeed = 15.0;

/**
    How many bombs the player can carry
*/
enum BombCountLimit = 5;