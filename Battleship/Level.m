//
//  Level.m
//  Battleship
//
//  Created by Michael Li on 4/6/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

#import "Level.h"

@implementation Level

-(id) init {
    // initialize arrays
    self.ships = [@[] mutableCopy];
    self.ship_positions = [@[] mutableCopy];
    self.hints = [@[] mutableCopy];
    
    return self;
}

@end
