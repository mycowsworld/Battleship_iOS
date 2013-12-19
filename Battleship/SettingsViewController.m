//
//  SettingsViewController.m
//  Battleship
//
//  Created by Michael Li on 4/8/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

#import "SettingsViewController.h"
#import "BattleshipAppDelegate.h"

@interface SettingsViewController ()
@end

// =========================
//
// IMPLEMENTATION
//
// =========================
@implementation SettingsViewController

// =========================
// CONSTRUCTOR
// =========================
//- (id)initWithStyle:(UITableViewStyle)style {
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

#pragma mark - System Events

// =========================
// VIEW DID LOAD
// =========================
- (void)viewDidLoad {
    [super viewDidLoad];

    // ======= SOUND
    // set current value of sound setting
    // get value from settings file
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    BOOL soundEnabled = [settings boolForKey:@"soundEnabled"];
    
    if (soundEnabled) {
        [self.sound_switch setOn:true];
    }
    else {
        [self.sound_switch setOn:false];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Change Settings

// =========================
// SELECT ITEM IN TABLE
// =========================
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // if clicked item is in the second section (second "group" of UI elements) and the first row/item in that section
    // (this refers to the "reset high scores" item)
    if (indexPath.section == 1 && indexPath.row == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reset High Score?"
                                                        message:@"Are you sure you want to reset high scores?"
                                                       delegate:self // delegate set to self => self will get a call back - need to implement delegate (see alertView didDismissWithButtonIndex)
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes",nil];
        [alert setTag:1]; // identifier for gameCompleted alert
        [alert show];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark Sound

// =========================
// SOUND SETTING CHANGED
// =========================
// if sound toggle is changed by user,
- (IBAction)soundSettingChanged {
    // retrieve the settings file
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    
    // change setting
    if (self.sound_switch.on) {
        [settings setBool:true forKey:@"soundEnabled"];
    }
    else {
        [settings setBool:false forKey:@"soundEnabled"];
    }
}

#pragma mark Reset High Scores

// =========================
// alert view delegate
// =========================
// delegate of alert view needs to implement UIAlertViewDelegate protocol
// tags are set in didSelectRowAtIndexPath
- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // RESTARTPRESSED
    if (alertView.tag == 1) {
        // cancel
        if (buttonIndex == 0) {
        }
        // OK
        else if (buttonIndex != alertView.cancelButtonIndex) {
            [self resetHighScores];
        }
    }
}

// =========================
// RESET HIGH SCORES
// =========================
- (void) resetHighScores {
    BattleshipAppDelegate* delegate = (BattleshipAppDelegate*) [[UIApplication sharedApplication] delegate];
    const char* dbPath = [delegate.databasePath UTF8String];
    sqlite3_stmt* statement;
    sqlite3* scoresDB;
    
    // open high scores database
    if (sqlite3_open(dbPath, &scoresDB) == SQLITE_OK) {
        // generate command to delete all entries in database
        NSString* query = [NSString stringWithFormat:@"DELETE FROM SCORES"];
        const char* delete_stmt = [query UTF8String];
        
        // execute command
        sqlite3_prepare_v2(scoresDB, delete_stmt, -1, &statement, NULL);
        
        // check results of execution
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Deleted");
        }
        else {
            NSLog(@"Error: Deleting Score");
        }
        
        // release compiled statement from memory
        sqlite3_finalize(statement);

        // close database connection
        sqlite3_close(scoresDB);
    }
}

@end
