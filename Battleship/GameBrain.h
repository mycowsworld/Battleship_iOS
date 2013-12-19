//
//  GameBrain.h
//  Battleship
//
//  Created by Michael Li on 3/30/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//
// *******************************************
//
// Model of Game
// used in BattleShipViewController
//
// *******************************************
#import <Foundation/Foundation.h>
#import "Level.h"

@interface GameBrain : NSObject
// =========================
// TYPEDEFS
// =========================
// BOARD VALUES
typedef enum : NSInteger {
    EMPTY = 0,
    WATER,
    SHIP
} TileValue;

// =========================
// PUBLIC VARIABLES
// =========================
@property (nonatomic) NSString* board_id;
@property (nonatomic) NSInteger board_size;

@property (nonatomic, strong) NSMutableArray* goal_row; // contains the target values for each column
@property (nonatomic, strong) NSMutableArray* goal_column; // contains the target values for each row
@property (nonatomic) BOOL complete_flag; // flag is set when level is completed

@property (nonatomic, strong) NSMutableArray* ships; // list of unique ships (sorted)
@property (nonatomic, strong) NSMutableDictionary* ship_map; // map of ship size -> number of ships


// =========================
// PUBLIC FUNCTIONS
// =========================
-(void) loadLevel:(Level *)level; // initialize game board with details of selected level
-(void) restartBoard; // reset the game board
-(NSInteger)getTileValueAtX:(NSInteger)x Y:(NSInteger)y; // retrieves TileValue of a given x,y position
-(void)setTileValueAtX:(NSInteger)x Y:(NSInteger)y withValue:(NSInteger)new_value; // sets a specific TileValue of a given x,y position
-(NSInteger)updateTileValueAtX:(NSInteger)x Y:(NSInteger)y; // increments a TileValue of a given x,y position
-(BOOL)isTileHintAtX:(NSInteger)x Y:(NSInteger)y; // check if a tile is a hint

- (NSMutableArray*)checkBoardState; // check the board to see if the solution has been found or if there are collisions
- (BOOL)checkBoardRow:(NSInteger) row; // check if a row meets the goal
- (BOOL)checkBoardColumn:(NSInteger) column; // check if a column meets the goal

- (BOOL) checkScore:(NSInteger) time; // checks if there is a new high score after player completes a level
@end
