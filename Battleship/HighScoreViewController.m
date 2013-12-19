//
//  HighScoreViewController.m
//  Battleship
//
//  Created by Michael Li on 4/10/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

#import "HighScoreViewController.h"
#import "BattleshipAppDelegate.h"
#import "Score.h"
#import <sqlite3.h>


@interface HighScoreViewController () <UIPickerViewDataSource, UIPickerViewDelegate>
    // also implements functions for UIPickerView object

// private property
@property (nonatomic, strong) NSMutableArray* boards; //

@end



@implementation HighScoreViewController

#pragma mark - System Events
// =========================
//
// VIEW DID LOAD
//
// =========================
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // populate initial list of scores
    self.score1.text = @"";
    self.score2.text = @"";
    self.score3.text = @"";
    
    // get unique list of levels that have high scores
    // (returns an array of numbers of board ids)
    self.boards = [self getBoards];
    
    // populate score labels with the first level that contains high scores
    if ([self.boards count] != 0) {
        NSNumber* value = [self.boards objectAtIndex:0];
        
        // returns the top three scores in an array
        NSMutableArray* scores = [self getScores:[value intValue]];
        
        // print them to the picker view
        [self populateScoresDisplay:scores];
    }
    // otherwise, hide the picker view
    else {
        self.score1.text = @"No high scores";
        self.pickerView.hidden = true;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Getters

// =========================
//
// GET BOARDS WITH HIGH SCORES
//
// =========================
- (NSMutableArray*)getBoards {
    NSMutableArray* boards = [[NSMutableArray alloc] init];
    BattleshipAppDelegate* delegate = (BattleshipAppDelegate*) [[UIApplication sharedApplication] delegate];
    const char* dbPath = [delegate.databasePath UTF8String];
    sqlite3_stmt* statement;
    sqlite3* scoresDB;
    
    // open database
    if (sqlite3_open(dbPath, &scoresDB) == SQLITE_OK) {
        NSString* query = [NSString stringWithFormat:@"SELECT DISTINCT BOARD FROM SCORES ORDER BY ID ASC"];
        const char* query_stmt = [query UTF8String];
        
        // query database for all unique boards
        if (sqlite3_prepare_v2(scoresDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
            // if at least one row returns
            if (sqlite3_step(statement) == SQLITE_ROW) {
                do {
                    NSNumber* board_id = [NSNumber numberWithInt:sqlite3_column_int(statement, 0)];
                    //NSLog(@"BOARD ID: %@", board_id);
                    
                    [boards addObject:board_id];
                } while (sqlite3_step(statement) == SQLITE_ROW);
            }
            
            sqlite3_finalize(statement); // release compiled statement from memory
        }
        else {
            NSLog(@"Failed SQL PREPARE. Error is: %s", sqlite3_errmsg(scoresDB));
        }
        
        // close database connection
        sqlite3_close(scoresDB);
    }
    
    return boards;
}

// =========================
//
// GET HIGH SCORES OF A BOARD
//
// =========================
- (NSMutableArray*)getScores:(NSInteger) board_id {
    BattleshipAppDelegate* delegate = (BattleshipAppDelegate*) [[UIApplication sharedApplication] delegate];
    const char* dbPath = [delegate.databasePath UTF8String];
    sqlite3_stmt* statement;
    sqlite3* scoresDB;
    
    NSMutableArray* scores = [[NSMutableArray alloc] init];
    
    // READ DATABASE
    if (sqlite3_open(dbPath, &scoresDB) == SQLITE_OK) {
        NSString* query = [NSString stringWithFormat:@"SELECT * FROM SCORES WHERE BOARD=%d ORDER BY RANK ASC", board_id];
        const char* query_stmt = [query UTF8String];
        
        // if at least one row returns
        if (sqlite3_prepare_v2(scoresDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {            
            // if at least one row returns
            if (sqlite3_step(statement) == SQLITE_ROW) {
                do {
                    Score* score = [[Score alloc] init];
                    score.score_id = sqlite3_column_int(statement, 0);
                    score.board_id = sqlite3_column_int(statement, 1);
                    score.minutes = sqlite3_column_int(statement, 2);
                    score.seconds = sqlite3_column_int(statement, 3);
                    score.rank = sqlite3_column_int(statement, 4);
                    
                    //NSLog(@"ID: %d, BOARD: %d, MIN: %d, SEC: %d, RANK: %d", score.score_id, score.board_id, score.minutes, score.seconds, score.rank);
                    [scores addObject:score];
                    
                } while (sqlite3_step(statement) == SQLITE_ROW);
            }
            // no scores for that board
            else {
            }
            
            sqlite3_finalize(statement); // release compiled statement from memory
        }
        else {
            NSLog(@"Failed SQL PREPARE. Error is: %s", sqlite3_errmsg(scoresDB));
        }
        
        // close database connection
        sqlite3_close(scoresDB);
    }
    
    return scores;
}

#pragma mark - Picker View
// =========================
//
// POPULATE PICKER VIEW
//
// =========================
- (void)populateScoresDisplay:(NSMutableArray*) scores {
    self.score1.text = @"";
    self.score2.text = @"";
    self.score3.text = @"";
    
    for (int i = 0; i < [scores count]; i++) {
        Score* score = [scores objectAtIndex:i];
        NSString* displaytext;
        if (score.seconds < 10) {
            displaytext = [NSString stringWithFormat:@"%d - %d:0%d", score.rank, score.minutes, score.seconds];
        }
        else {
            displaytext = [NSString stringWithFormat:@"%d - %d:%d", score.rank, score.minutes, score.seconds];
        }
        
        if (i == 0) {
            self.score1.text = displaytext;
        }
        else if (i == 1) {
            self.score2.text = displaytext;
        }
        else if (i == 2) {
            self.score3.text = displaytext;
        }
    }
}

// =========================
//
// PICKER VIEW PARAMETERS
//
// =========================
// number of components (just one component)
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    return 1;
}
// number of items in a component (number of boards that contain high scores)
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.boards count];
}
// populate items in a component
- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSNumber* value = [self.boards objectAtIndex:row];
    return [NSString stringWithFormat:@"Board %@", value];
}
// handle selecting an item
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    //NSLog(@"Selected Board: %@. Index of selected color: %i", [self.boards objectAtIndex:row], row);
    NSNumber* value = [self.boards objectAtIndex:row];
    NSMutableArray* scores = [self getScores:[value intValue]];
    [self populateScoresDisplay:scores];
}
@end
