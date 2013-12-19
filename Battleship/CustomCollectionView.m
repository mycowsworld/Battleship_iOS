//
//  CustomCollectionView.m
//  Battleship
//
//  Created by Michael Li on 4/9/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

// header
#import "CustomCollectionView.h"
//
#import "BattleshipViewController.h"
#import "GameTile.h"


@implementation CustomCollectionView

// =========================
// CONSTRUCTOR
// =========================
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Touch Events

// =========================
// touchesBegan
// =========================
// user touched collection view container
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // obtain reference to the collection view that was touched
    UITouch* touch = [[event allTouches] anyObject];
    UIView* view = touch.view;

    // determine what tile was touched by user
    // loop through subviews
    for (int i = 0; i < [view.subviews count]; i++) {
        // if a subview is a UIButton
        // with tag = 1 (game tile)
        if ([[view.subviews objectAtIndex:i] isKindOfClass:[UIButton class]] && [[view.subviews objectAtIndex:i] tag] == 1) {
            //if (controller && [controller isKindOfClass:[BattleshipViewController class]]) {
                BattleshipViewController* controller = (BattleshipViewController*) self.superview.nextResponder;
                UIButton* tile = [view.subviews objectAtIndex:i];
                [controller tilePressed:tile]; // notify game
            //}
        }
    }
}

// =========================
// touchesMoved
// =========================
// user dragged finger across collection view (after touchesBegan)
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    BattleshipViewController* controller = (BattleshipViewController*) self.superview.nextResponder;
    CGPoint tappedPt = [[touches anyObject] locationInView: self]; 
    [controller tilePressedDragAtPoint:tappedPt]; // notify view controller
}

// =========================
// touchesEnded
// =========================
// user lifted finger after dragging
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    BattleshipViewController* controller = (BattleshipViewController*) self.superview.nextResponder;
    [controller tilePressedDragEnd]; // notify view controller
}


@end
