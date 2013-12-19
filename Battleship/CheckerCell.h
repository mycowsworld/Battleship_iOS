//
//  CheckerCell.h
//  Battleship
//
//  Created by Michael Li on 4/7/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//
// *******************************************
//
// CheckerCell class
// used in GameBrain to check if tiles in the board are
// "colliding"
//
// *******************************************
#import <Foundation/Foundation.h>

@interface CheckerCell : NSObject

@property (nonatomic) NSInteger value; // value of tile (either  0 or whatever the value is of TileState)
@property (nonatomic) NSInteger group; // id of group

@end
