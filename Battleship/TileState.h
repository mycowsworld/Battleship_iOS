//
//  TileState.h
//  Battleship
//
//  Created by Michael Li on 4/5/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//
// *******************************************
//
// TileState Class
// GameBrain's representation of the game board
// contains the current value of a tile
//
// *******************************************
#import <Foundation/Foundation.h>

@interface TileState : NSObject

@property (nonatomic) NSInteger value; // the current value of that tile (values = TileValues defined in GameBrain)
@property (nonatomic) BOOL hint; // marks whether a tile is a hint or not (prevents the tile from being updated by player)

@end
