//
//  BattleshipAppDelegate.h
//  Battleship
//
//  Created by Michael Li on 3/29/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sqlite3.h>

@interface BattleshipAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow* window;
@property (nonatomic, strong) NSString* databasePath; // path to SQL Database of high scores
@end
