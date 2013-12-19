//
//  BattleshipAppDelegate.m
//  Battleship
//
//  Created by Michael Li on 3/29/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

#import "BattleshipAppDelegate.h"
#import <sqlite3.h> // SQL Database

@implementation BattleshipAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // ========================
    // # Set Default Settings
    // ========================
    // tell game to use settings defined in the settings file
    // stored in defaults.plist (in resources)
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]]];
    
    // ========================
    // # Check if High Score Database has been created
    // ========================
    NSString* docsDir;
    NSArray* dirPaths;
    
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); // get a list of directories that are owned by the application
    docsDir = dirPaths[0]; //
    self.databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"scores.db"]]; // this is the expected path to where the database should live ('docsDir . "/scores.db/')
    
    NSFileManager *filemgr = [NSFileManager defaultManager]; // define filemanager. this is used to look up if a file exists or not
    
    // if database file doesn't exist, create it
    if ([filemgr fileExistsAtPath:self.databasePath] == NO) {
        const char* dbPath = [self.databasePath UTF8String]; // convert pathname to UTF8 String
        sqlite3* scoresDB; // stores pointer to high scores database
        if (sqlite3_open(dbPath, &scoresDB) == SQLITE_OK) { // create a database at the specified path
            char* errorMsg;
            const char* sql_stmt = "CREATE TABLE IF NOT EXISTS SCORES (ID INTEGER PRIMARY KEY AUTOINCREMENT, BOARD INTEGER, MINUTES INTEGER, SECONDS INTEGER, RANK INTEGER);";
    
            // create table in database
            if (sqlite3_exec(scoresDB, sql_stmt, NULL, NULL, &errorMsg) != SQLITE_OK) {
                //NSLog(@"Failed to create table");
            }
            //else {
            //    NSLog(@"Created table");
            //}
            
            sqlite3_close(scoresDB);
        }
        else {
            NSLog(@"Failed to open/create database");
        }
    }
    // else use self.databasePath
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
