//
//  GameTile.h
//  Battleship
//
//  Created by Michael Li on 4/3/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//
// *******************************************
//
// GameTile Class
// represents a tile in the Game Board collection view (CustomCollectionView)
// (a subview of CustomCollectionView)
//
// *******************************************
#import <Foundation/Foundation.h>

@interface GameTile : UICollectionViewCell

@property(nonatomic) NSInteger row;
@property(nonatomic) NSInteger column;
@property(nonatomic, strong) IBOutlet UIButton* button;

@end
