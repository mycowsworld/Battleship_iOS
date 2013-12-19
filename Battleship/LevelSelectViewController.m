//
//  LevelSelectViewController.m
//  Battleship
//
//  Created by Michael Li on 3/29/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

#import "LevelSelectViewController.h"
#import "BattleshipViewController.h"
#import "Level.h"

#define FILE_NAME @"levels" // name of text file that contains levels information

@interface LevelSelectViewController ()

@property (nonatomic, strong) NSMutableArray* levels; // stores all the levels (class: Levels) defined in the text file
@property (nonatomic, strong) Level* selected_level; // level selected by user

@end

// =========================
//
// IMPLEMENTATION
//
// =========================
@implementation LevelSelectViewController

#pragma mark - System Events

// =========================
// VIEW DID LOAD
// =========================
- (void)viewDidLoad {
    [super viewDidLoad];
	
    // initialize array
    self.levels = [[NSMutableArray alloc] init];
    
    // read text file that defines levels
    // stores them in self.levels
    // readFile is defined below
    [self readFile];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// =========================
// PREPARE FOR SEGUE
// =========================
// this function is called when invoking performSegueWithIdentifier
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // SEGUE: MOVING TO GAME SCREEN
    // pass selected level to the new view controller
    if ([segue.identifier isEqualToString:@"levelselected"]) {
        BattleshipViewController* controller = (BattleshipViewController *)segue.destinationViewController;
        controller.level = self.selected_level;
    }
}

#pragma mark - File Parsing

// =========================
// READ FILE
// =========================
// reads text file containing level details
// stores in self.levels
- (void)readFile {
    // retrieve file
    NSString* fileRoot = [[NSBundle mainBundle] pathForResource:FILE_NAME ofType:@"txt"];
    
    // read everything from text
    NSString* fileContents = [NSString stringWithContentsOfFile:fileRoot encoding:NSUTF8StringEncoding error:nil];
    
    // separate by new line
    NSArray* allLines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    // read all lines
    Level *level;
    for (int i = 0; i < [allLines count]; i++) {
        NSString* line = [allLines objectAtIndex:i];
        if ([line rangeOfString:@"Board"].location != NSNotFound) {
            // create new level
            level = [[Level alloc] init];
            
            // e.g. Board 1
            NSArray* parts = [[NSArray alloc] init];
            parts = [line componentsSeparatedByString:@" "];
            //level.board_id = [[parts objectAtIndex:1] intValue];
            level.board_id = [parts objectAtIndex:1];
            
            // e.g. 6
            i++;
            line = [allLines objectAtIndex:i];
            level.board_size = [line intValue];
            
            // store level in levels
            [self.levels addObject:level];
        }
        else if ([line rangeOfString:@"hint"].location != NSNotFound) {
            // e.g. hint:4,1
            NSArray* parts = [[NSArray alloc] init];
            parts = [line componentsSeparatedByString:@":"];
            
            [level.hints addObject:[parts objectAtIndex:1]];
        }
        else if ([line rangeOfString:@":"].location != NSNotFound) {
            // e.g. 3:4,5,6,5
            NSArray* parts = [[NSArray alloc] init];
            parts = [line componentsSeparatedByString:@":"];
            
            [level.ships addObject:[parts objectAtIndex:0]];
            [level.ship_positions addObject:[parts objectAtIndex:1]];
        }
    }
}

#pragma mark - Table View Data Source

// =========================
// NUMBER OF TABLE SECTIONS
// =========================
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections
    // only one section/group in table
    return 1;
}
// =========================
// NUMBER OF TABLE ROWS
// =========================
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.levels.count;
}
// =========================
// POPULATE TABLE
// =========================
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Level* level = [self.levels objectAtIndex:indexPath.row];
    
    static NSString *CellIdentifier = @"LevelCell"; // defined in StoryBoard (CustomCollectionView)
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // set cell parameters
    cell.textLabel.text = [NSString stringWithFormat:@"Board %@ (%dx%d)",level.board_id, level.board_size,level.board_size];

    return cell;
}

#pragma mark - Table View Delegate

// =========================
// SELECT ITEM IN TABLE
// =========================
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // save selected level
    self.selected_level = [self.levels objectAtIndex:indexPath.row];
    
    // activate LEVELSELECTED segue
    // "levelselected" is defined in the storyboard
    // (see the "attributes" of the segue between the Level Select and Battleship View Controllers)
    [self performSegueWithIdentifier:@"levelselected" sender:self];
}


@end
