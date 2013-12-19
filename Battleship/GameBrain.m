//
//  GameBrain.m
//  Battleship
//
//  Created by Michael Li on 3/30/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

// header
#import "GameBrain.h"
// classes
#import "TileState.h"
#import "Level.h"
#import "CheckerCell.h"
#import "BattleshipAppDelegate.h"
#import "Score.h"
// toolboxes
#import <sqlite3.h>


// =========================
// CONSTANTS
// =========================
static const NSInteger NUMBEROFHIGHSCORES = 3; // number of high scores per level

// =========================
//
// INTERFACE
//
// =========================
@interface GameBrain()

@property (nonatomic, strong) NSMutableArray* board_state; // maintains state of board (board_size x board_size grid of TileState objects)
@property (nonatomic, strong) NSMutableArray* board_checker; // used in ship collision checking ((board_size x board_size grid of CheckerCell objects)
@property (nonatomic, strong) NSMutableArray* collided; // tells view controller which tiles are in collision (board_size x board_size grid of NSNumbers. 0 = tile is not colliding. 1 = tile is colliding.
@property (nonatomic, strong) NSMutableDictionary* bad_groups; // list of groups that are in collision
@property (nonatomic) NSInteger group_count; // current group number. used when checking for collisions

@end

// =========================
//
// IMPLEMENTATION
//
// =========================
@implementation GameBrain

// =========================
// CONSTRUCTOR
// =========================
-(id)init {
    // initialize arrays
    self.board_state = [[NSMutableArray alloc] init];
    self.goal_row = [[NSMutableArray alloc] init];
    self.goal_column = [[NSMutableArray alloc] init];
    self.collided = [[NSMutableArray alloc] init];
    self.board_checker = [[NSMutableArray alloc] init];
    self.ships = [[NSMutableArray alloc] init];
    self.ship_map = [[NSMutableDictionary alloc] init];
    self.bad_groups = [[NSMutableDictionary alloc] init];
    return self;
}

#pragma mark - Loading

// =========================
// LOAD LEVEL
// =========================
// load level details into model
-(void) loadLevel:(Level *) level {
    // store board information
    self.board_id = level.board_id;
    self.board_size = level.board_size;
    
    // ====================
    // initialize arrays
    // ====================
    // solution
    NSMutableArray* solution = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.board_size; i++) {
        // board_state - add row
        NSMutableArray* row = [[NSMutableArray alloc] init];
        [self.board_state addObject:row];
        
        // solution - add row
        row = [[NSMutableArray alloc] init];
        [solution addObject:row];
        
        // collided - add row
        row = [[NSMutableArray alloc] init];
        [self.collided addObject:row];
        
        for (int j = 0; j < self.board_size; j++) {
            // board_state - fill rows with TileStates
            TileState* tile = [[TileState alloc] init];
            tile.value = EMPTY;
            tile.hint = false;
            [[self.board_state objectAtIndex:i] addObject:tile];
            
            // solution - fill rows with CheckerCells
            CheckerCell* cell = [[CheckerCell alloc] init];
            cell.value = WATER;
            [[solution objectAtIndex:i] addObject:cell];
            
            // collided - fill with zeros
            NSNumber* number = [[NSNumber alloc] init];
            number = [NSNumber numberWithInt:0];
            [[self.collided objectAtIndex:i] addObject:number];
        }
    }
    
    // ====================
    // solution map
    // ====================
    // go through all the ships and map out the solution in a grid
    for (int i = 0; i < [level.ship_positions count]; i++) {
        NSArray* parts = [[NSArray alloc] init];
        parts = [[level.ship_positions objectAtIndex:i] componentsSeparatedByString:@","];
        
        // 1x1 ship
        if ([parts count] == 2) {
            NSInteger x = [[parts objectAtIndex:0] intValue] - 1;
            NSInteger y = [[parts objectAtIndex:1] intValue] - 1;
            CheckerCell* cell = [[solution objectAtIndex:x] objectAtIndex:y];
            cell.value = SHIP;
        }
        // bigger ship
        else if ([parts count] == 4) {
            NSInteger x1 = [[parts objectAtIndex:0] intValue] - 1;
            NSInteger y1 = [[parts objectAtIndex:1] intValue] - 1;
            NSInteger x2 = [[parts objectAtIndex:2] intValue] - 1;
            NSInteger y2 = [[parts objectAtIndex:3] intValue] - 1;
            if (x1 == x2) {
                for (int j = y1; j <= y2; j++) {
                    CheckerCell* cell = [[solution objectAtIndex:x1] objectAtIndex:j];
                    cell.value = SHIP;
                }
            }
            else if (y1 == y2) {
                for (int j = x1; j <= x2; j++) {
                    CheckerCell* cell = [[solution objectAtIndex:j] objectAtIndex:y1];
                    cell.value = SHIP;
                }
            }
        }
    }
    
    // ====================
    // goal row/column
    // ====================
    // calculate the goal values for each row/column based on solution map
    for (int i = 0; i < self.board_size; i++) {
        NSInteger row_count = 0;
        NSInteger col_count = 0;
        for (int j = 0; j < self.board_size; j++) {
            CheckerCell* cell = [[solution objectAtIndex:i] objectAtIndex:j];
            if (cell.value == SHIP) { col_count++; }
            
            cell = [[solution objectAtIndex:j] objectAtIndex:i];
            if (cell.value == SHIP) { row_count++; }
        }
        [self.goal_column addObject:[NSNumber numberWithInteger:row_count]];
        [self.goal_row addObject:[NSNumber numberWithInteger:col_count]];
    }

    // ====================
    // hints
    // ====================
    // mark the appropriate cells in the current game board state as hints and set the cell to the appropriate value
    for (int i = 0; i < [level.hints count]; i++) {
        NSArray* parts = [[NSArray alloc] init];
        parts = [[level.hints objectAtIndex:i] componentsSeparatedByString:@","];
        
        NSInteger x = [[parts objectAtIndex:0] intValue] - 1;
        NSInteger y = [[parts objectAtIndex:1] intValue] - 1;
        
        TileState* tile = [[self.board_state objectAtIndex:x] objectAtIndex:y];
        CheckerCell* cell = [[solution objectAtIndex:x] objectAtIndex:y];
        tile.value = cell.value;
        tile.hint = true;
    }
    
    // ====================
    // ships
    // ====================
    // determine total number of ships per ship type
    NSInteger current_ship = 0;
    NSInteger ship_count = 0;
    for (int i = 0; i < [level.ships count]; i++) {
        NSInteger this_ship = [[level.ships objectAtIndex:i] intValue];
        // if the ship size is "new"
        if (current_ship != this_ship) {
            if (current_ship != 0) {
                // store current ship into array/map
                [self.ship_map setValue:[NSNumber numberWithInteger:ship_count] forKey:[NSString stringWithFormat:@"%d", current_ship]];
                [self.ships addObject:[NSNumber numberWithInteger:current_ship]];
            }
            // start new count
            current_ship = this_ship;
            ship_count = 1;
        }
        // increment count on current ship type
        else {
            ship_count++;
        }
    }
    // add last set to map
    [self.ship_map setValue:[NSNumber numberWithInteger:ship_count] forKey:[NSString stringWithFormat:@"%d", current_ship]];
    [self.ships addObject:[NSNumber numberWithInteger:current_ship]];
    // sort ships
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:NO];
    [self.ships sortUsingDescriptors:[NSArray arrayWithObject:highestToLowest]];
    
    // ====================
    // board_checker
    // ====================
    // initialize array that will be used to check for collisions
    for (int i = 0; i < self.board_size + 2; i++) {
        NSMutableArray* row = [[NSMutableArray alloc] init];
        [self.board_checker addObject:row];
        
        for (int j = 0; j < self.board_size + 2; j++) {
            CheckerCell* cell = [[CheckerCell alloc] init];
            cell.value = EMPTY;
            [[self.board_checker objectAtIndex:i] addObject:cell];
        }
    }
}

// =========================
// CHECK HIGH SCORE
// =========================
- (BOOL) checkScore:(NSInteger) time {
    // database variables
    BattleshipAppDelegate* delegate = (BattleshipAppDelegate*) [[UIApplication sharedApplication] delegate];
    const char* dbPath = [delegate.databasePath UTF8String];
    sqlite3_stmt* statement;
    sqlite3* scoresDB;
    
    // score variables
    NSMutableArray* scores = [[NSMutableArray alloc] init];
    BOOL newhighscore = false;
    NSInteger rank = -1;
    NSInteger minutes = time / 60;
    NSInteger seconds = time % 60;

    // READ DATABASE
    if (sqlite3_open(dbPath, &scoresDB) == SQLITE_OK) {
        NSString* query = [NSString stringWithFormat:@"SELECT * FROM SCORES WHERE BOARD=%@ ORDER BY RANK ASC", self.board_id];
        const char* query_stmt = [query UTF8String];
        
        // if at least one row returns
        if (sqlite3_prepare_v2(scoresDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            // if at least one row returns
            if (sqlite3_step(statement) == SQLITE_ROW) {
                do {
                    Score* score = [[Score alloc] init];
                    score.score_id = sqlite3_column_int(statement, 0);
                    score.board_id = sqlite3_column_int(statement, 1);
                    score.minutes = sqlite3_column_int(statement, 2);
                    score.seconds = sqlite3_column_int(statement, 3);
                    score.rank = sqlite3_column_int(statement, 4);
                    
                    //NSLog(@"ID: %d, BOARD: %d, MIN: %d, SEC: %d, RANK: %d", score.score_id, score.board_id, score.minutes, score.seconds, score.rank);
                    [scores addObject:score];
                    
                } while (sqlite3_step(statement) == SQLITE_ROW);
            }
            // no scores for that board
            else {
            }
            
            sqlite3_finalize(statement); // release compiled statement from memory
        }
        else {
            NSLog(@"Failed SQL PREPARE. Error is: %s", sqlite3_errmsg(scoresDB));
        }
        
        
        // CHECK SCORES
        if ([scores count] == 0) {
            rank = 1;
            newhighscore = true;
        }
        else {
            for (int i = 0; i < [scores count]; i++) {
                Score* score = [scores objectAtIndex:i];
                if (minutes < score.minutes) {
                    rank = i+1;
                    newhighscore = true;
                    break;
                }
                else if (minutes == score.minutes) {
                    if (seconds < score.seconds) {
                        rank = i+1;
                        newhighscore = true;
                        break;
                    }
                }
            }
            if ([scores count] < NUMBEROFHIGHSCORES) {
                if (rank == -1) { rank = [scores count] + 1; newhighscore = true; }
            }
        }
        
        // UPDATE DATABASE
        // if there is a new high score, update database to reflect new rankings
        if (newhighscore) {
            for (int i = rank-1; i < [scores count]; i++) {
                Score* score = [scores objectAtIndex:i];
                // delete last entry (if pushed off leaderboard)
                if (i == [scores count] - 1 && [scores count] == NUMBEROFHIGHSCORES) {
                    NSString* delete = [NSString stringWithFormat:@"DELETE FROM SCORES WHERE ID=\"%d\"", score.score_id];
                    const char* delete_stmt = [delete UTF8String];
                    sqlite3_prepare_v2(scoresDB, delete_stmt, -1, &statement, NULL);
                    
                    if (sqlite3_step(statement) == SQLITE_DONE) {
                        //NSLog(@"deleted");
                    }
                    else {
                        NSLog(@"Error: Deleting Score");
                    }
                }
                // update existing entries with new ranks
                else {
                    NSString* update = [NSString stringWithFormat:@"UPDATE SCORES SET RANK=\"%d\" WHERE ID=\"%d\"", i+2, score.score_id];
                    const char* update_stmt = [update UTF8String];
                    sqlite3_prepare_v2(scoresDB, update_stmt, -1, &statement, NULL);
                    
                    if (sqlite3_step(statement) == SQLITE_DONE) {
                        //NSLog(@"updated");
                    }
                    else {
                        NSLog(@"Error: Updating Score");
                    }
                }
            }
            
            // add new score to database
            NSString* insert = [NSString stringWithFormat:@"INSERT INTO SCORES (BOARD, MINUTES, SECONDS, RANK) VALUES (\"%@\", \"%d\", \"%d\", \"%d\")", self.board_id, minutes, seconds, rank];
            const char* insert_stmt = [insert UTF8String];
            sqlite3_prepare_v2(scoresDB, insert_stmt, -1, &statement, NULL);
            
            if (sqlite3_step(statement) == SQLITE_DONE) {
                //NSLog(@"added");
            }
            else {
                NSLog(@"Error: Adding Score");
            }
            
            sqlite3_finalize(statement);
        }

        // close database connection
        sqlite3_close(scoresDB);
    }
    
    return newhighscore;
}


#pragma mark - Board Management
// =========================
// GET TILE VALUE
// =========================
-(NSInteger)getTileValueAtX:(NSInteger)x
                          Y:(NSInteger)y {
    TileState* tile = [[self.board_state objectAtIndex:x] objectAtIndex:y];
    return tile.value;
}

// =========================
// SET TILE VALUE
// =========================
-(void)setTileValueAtX:(NSInteger)x
                     Y:(NSInteger)y
             withValue:(NSInteger)new_value {
    TileState* tile = [[self.board_state objectAtIndex:x] objectAtIndex:y];
    tile.value = new_value;
}

// =========================
// UPDATE TILE VALUE
// =========================
-(NSInteger)updateTileValueAtX:(NSInteger)x
                             Y:(NSInteger)y {
    TileState* tile = [[self.board_state objectAtIndex:x] objectAtIndex:y];
    if (tile.value == EMPTY) {
        tile.value = WATER;
    }
    else if (tile.value == WATER) {
        tile.value = SHIP;
    }
    else if (tile.value == SHIP) {
        tile.value = EMPTY;
    }
    else {
        tile.value = EMPTY;
    }
    
    return tile.value;
}

// =========================
// IS TILE HINT
// =========================
-(BOOL)isTileHintAtX:(NSInteger)x
                   Y:(NSInteger)y {
    TileState* tile = [[self.board_state objectAtIndex:x] objectAtIndex:y];
    return tile.hint;
}

// =========================
// RESTART BOARD
// =========================
-(void) restartBoard {
    for (int i = 0; i < self.board_size; i++) {
        for (int j = 0; j < self.board_size; j++) {
            TileState* tile = [[self.board_state objectAtIndex:i] objectAtIndex:j];
            if (tile.hint == false)
                tile.value = EMPTY;
        }
    }
}


#pragma mark - Board Checking

// =========================
// CHECK BOARD ROW
// =========================
// check if a row in the game board matches the goal
- (BOOL)checkBoardRow:(NSInteger) row {
    // calculate current value of the row
    NSInteger row_count = 0;
    for (int i = 0; i < self.board_size; i++) {
        TileState* cell = [[self.board_state objectAtIndex:i] objectAtIndex:row];
        if (cell.value == SHIP) { row_count++; }
    }
    
    // compare current value with goal
    if (row_count != [[self.goal_column objectAtIndex:row] integerValue]) {
        return false;
    }
    else {
        return true;
    }
}

// =========================
// CHECK BOARD COLUMN
// =========================
// check if a column in the game board matches the goal
- (BOOL)checkBoardColumn:(NSInteger) column {
    // calculate current value of the column
    NSInteger col_count = 0;
    for (int i = 0; i < self.board_size; i++) {
        TileState* cell = [[self.board_state objectAtIndex:column] objectAtIndex:i];
        if (cell.value == SHIP) { col_count++; }
    }
    
    // compare current value with goal
    if (col_count != [[self.goal_row objectAtIndex:column] integerValue]) {
        return false;
    }
    else {
        return true;
    }
}

// =========================
// CHECK BOARD STATE
// =========================
// check entire game board
// - is board complete?
// - are there colliding ships?
- (NSMutableArray*)checkBoardState {
    BOOL completed = true; // flag if all game conditions are met
    
    // refresh/re-initialize collided
    for (int i = 0; i < self.board_size; i++) {
        for (int j = 0; j < self.board_size; j++) {
            NSNumber* number = [NSNumber numberWithInt:0];
            [[self.collided objectAtIndex:i] replaceObjectAtIndex:j withObject:number];
        }
    }
    completed = [self checkCollisions];
    
    // check state of board (does board match goal?)
    for (int i = 0; i < self.board_size; i++) {
        // count current number of ships in rows/columns
        NSInteger row_count = 0;
        NSInteger col_count = 0;
        for (int j = 0; j < self.board_size; j++) {
            TileState* cell = [[self.board_state objectAtIndex:i] objectAtIndex:j];
            if (cell.value == SHIP) { col_count++; }
        
            cell = [[self.board_state objectAtIndex:j] objectAtIndex:i];
            if (cell.value == SHIP) { row_count++; }
        }
        // enough ships in column?
        if (row_count != [[self.goal_column objectAtIndex:i] integerValue]) { completed = false; }
        if (col_count != [[self.goal_row objectAtIndex:i] integerValue]) { completed = false; }
    }
    
    // if completed is still true, then level is completed
    if (completed == true) { self.complete_flag = true; }
    
    return self.collided;
}

// =========================
// CHECK COLLISIONS
// =========================
// the board_checker will copy the current state of the game board as well as surrounding the game board with a "border" of "0"-state tiles.
// the algorithm will start with the top-left cell of the "copied" game board (position 1,1 in board_checker) and traverse until a ship cell is found. then, check all of its adjacent cells. If there is a ship cell that is to the top, left, right, or bottom of the cell, then it is in the same group. If a ship cell is on one of the corners, then there is a "collision" and the group is now a "bad group"
- (BOOL)checkCollisions {
    // initialize board_checker
    for (int i = 0; i < self.board_size+2; i++) {
        for (int j = 0; j < self.board_size+2; j++) {
            CheckerCell* cell = [[self.board_checker objectAtIndex:i] objectAtIndex:j];
            cell.group = 0;
            
            if (i == 0 || i == self.board_size+1 || j == 0 || j == self.board_size+1) {
                cell.value = EMPTY;
            }
            else {
                TileState* tile = [[self.board_state objectAtIndex:i-1] objectAtIndex:j-1];
                cell.value = tile.value;
            }
        }
    }
    [self.bad_groups removeAllObjects];
    self.group_count = 1;
    
    // identify groups of cells, determine which groups are in violation
    for (int i = 0; i < self.board_size; i++) {
        for (int j = 0; j < self.board_size; j++) {
            // start in cell 1,1
            NSInteger x = i+1;
            NSInteger y = j+1;
            CheckerCell* cell = [[self.board_checker objectAtIndex:x] objectAtIndex:y];
            
            // if the cell is currently a ship cell and no group has been assigned yet
            if (cell.value == SHIP && cell.group == 0) {
                cell.group = self.group_count;
                [self checkSurroundingsAtX:x Y:y];
                self.group_count++;
            }
        }
    }
    
    // identify cells in violation, add it to the "collided" array
    for (int i = 0; i < self.board_size; i++) {
        for (int j = 0; j < self.board_size; j++) {
            NSInteger x = i+1;
            NSInteger y = j+1;
            CheckerCell* cell = [[self.board_checker objectAtIndex:x] objectAtIndex:y];
            
            if ([self.bad_groups objectForKey:[NSString stringWithFormat:@"%d",cell.group]] != nil) {
                NSNumber* number = [NSNumber numberWithInt:1];
                [[self.collided objectAtIndex:i] replaceObjectAtIndex:j withObject:number];
            }
            
        }
    }
    /*
    NSLog(@"CHECK COLLISIONS");
    for (int i = 0; i < self.board_size; i++) {
        NSString* string = [[NSString alloc] init];
        for (int j = 0; j < self.board_size; j++) {
            NSNumber* value = [[self.collided objectAtIndex:i] objectAtIndex:j];
            string = [NSString stringWithFormat:@"%@ %@", string, value];
        }
        NSLog(@"%@", string);
    }
    */
    // if no bad groups, then board is clean
    if ([self.bad_groups count] == 0)
        return true;
    else
        return false;
}

// =========================
// CHECK SURROUNDINGS
// =========================
- (void)checkSurroundingsAtX:(NSInteger)x
                           Y:(NSInteger)y {
    // cycle through adjacent cells
    for (int i = x-1; i <= x+1; i++) {
        for (int j = y-1; j <= y+1; j++) {
            // skip yourself
            if (i == x && j == y)
                continue;
            
            // if an adjacent cell is a ship cell, add it to the group. 
            CheckerCell* cell = [[self.board_checker objectAtIndex:i] objectAtIndex:j];
            if (cell.value == SHIP) {
                if (cell.group == 0) {
                    cell.group = self.group_count;
                    [self checkSurroundingsAtX:i Y:j];
                }
        
                // if an adjacent cell is a corner cell, then it is in violation
                if (i != x && j != y) {
                    [self.bad_groups setValue:[NSNumber numberWithInteger:1] forKey:[NSString stringWithFormat:@"%d", self.group_count]];
                }
            }
        }
    }
}

@end
