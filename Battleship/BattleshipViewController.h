//
//  BattleshipViewController.h
//  Battleship
//
//  Created by Michael Li on 3/29/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//
// *******************************************
//
// View Controller for Game Board
//
// *******************************************
#import <UIKit/UIKit.h>
// objects
#import "Level.h"


@interface BattleshipViewController : UIViewController
// =========================
// VIEW POINTERS
// =========================
// weak - view already has a strong pointer to these entities
// nonatomic - "not thread safe"
@property (weak, nonatomic) IBOutlet UILabel *timer_label; // label containing time elapsed
@property (weak, nonatomic) IBOutlet UICollectionView *board_layout; // grid containing board tiles

// =========================
// PUBLIC PROPERTIES
// =========================
@property (nonatomic, strong) Level* level; // selected level from LevelSelectViewController

// =========================
// BUTTON PRESSES
// =========================
- (IBAction)restartPressed; // restart button pressed on view

// =========================
// COLLECTION VIEW EVENTS
// =========================
- (void) tilePressed:(id)sender; // tile was pressed in CustomCollectionView
- (void) tilePressedDragAtPoint:(CGPoint)point; // tile was dragged over in CustomCollectionView
- (void) tilePressedDragEnd; // tile dragging ended

@end
