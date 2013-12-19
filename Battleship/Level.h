//
//  Level.h
//  Battleship
//
//  Created by Michael Li on 4/6/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//
// *******************************************
//
// Level Class
// properties of a level in the game
//
// *******************************************
#import <Foundation/Foundation.h>

@interface Level : NSObject

@property (nonatomic) NSString* board_id; // board id/level number
@property (nonatomic) NSInteger board_size; // size of board (number of tiles in a row/column)
@property (nonatomic) NSMutableArray* ships; // ships contained in this level. each index provides the size of the ship
@property (nonatomic) NSMutableArray* ship_positions; // x,y positions of ships (index of this array corresponds to the index of the "ships" array)
@property (nonatomic) NSMutableArray* hints; // x,y positions of hints on the board

@end
