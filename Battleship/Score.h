//
//  Score.h
//  Battleship
//
//  Created by Michael Li on 4/12/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//
// *******************************************
//
// Score Class
// represents a score entity when reading high scores from scores database
//
// *******************************************
#import <Foundation/Foundation.h>

@interface Score : NSObject

@property (nonatomic) NSInteger score_id; // id of score in SQL table
@property (nonatomic) NSInteger board_id; // board the score belongs to
@property (nonatomic) NSInteger minutes; // completion time: minutes
@property (nonatomic) NSInteger seconds; // completion time: seconds
@property (nonatomic) NSInteger rank; // high score rank for the board_id

@end
