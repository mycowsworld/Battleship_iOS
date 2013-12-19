//
//  BattleshipViewController.m
//  Battleship
//
//  Created by Michael Li on 3/29/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

// header
#import "BattleshipViewController.h"
// toolboxes
//#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h> // audio/video player
// objects
#import "GameBrain.h"
#import "GameTile.h"
#import "Level.h"

// Also implements UICollectionViewDataSource and UICollectionViewDelegateFlowLayout
// (UICollectionViewDelegateFlowLayout also includes UICollectionViewDelegate)
@interface BattleshipViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

// =========================
// Private Variables
// =========================
@property (nonatomic, strong) GameBrain* brain; // game logic
@property (nonatomic) NSInteger tiles_count; // total number of tiles (game tiles, goal tiles)
@property (nonatomic, strong) NSMutableArray* game_tiles; // stores GameTiles representing game board
@property (nonatomic, strong) NSMutableArray* goal_row_tiles; // stores GameTiles row of goal numbers
@property (nonatomic, strong) NSMutableArray* goal_column_tiles; // stores GameTiles column of goal numbers
@property (nonatomic, strong) GameTile* touchStarter; // stores pointer to GameTile that user first touched in a touch/drag action

@property (nonatomic, strong) NSTimer* timer; // stores reference to timer
@property (nonatomic) NSInteger time; // length of time spent on level (units: seconds)
@property (nonatomic, strong) NSMutableArray* soundplayers; // stores AVAudioPlayers

@end


// =========================
//
// IMPLEMENTATION
//
// =========================
@implementation BattleshipViewController

// =========================
// BRAIN GETTER
// =========================
// need to access instance variable
- (GameBrain*) brain {
    // lazy instantiation
    if (!_brain)
        _brain = [[GameBrain alloc] init];
    return _brain;
}


#pragma mark - System Events
// =========================
// VIEW DID LOAD
// =========================
// once view is loaded, initialize variables and other game settings
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // load sounds
    [self setupSounds];
    
    // initialize arrays
    self.game_tiles = [[NSMutableArray alloc] init];
    self.goal_row_tiles = [[NSMutableArray alloc] init];
    self.goal_column_tiles = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.level.board_size; i++) {
        NSMutableArray* tiles_row = [[NSMutableArray alloc] init];
        [self.game_tiles addObject:tiles_row];
    }
    
    // load selected level
    [self.brain loadLevel:self.level];
    
    // draw game board
    self.navigationItem.title = [NSString stringWithFormat:@"Board %@", self.brain.board_id];
    [self drawScreen];
    
    // start timer
    self.time = 0;
    [self startTimer];
    
    // start background music
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    BOOL soundEnabled = [settings boolForKey:@"soundEnabled"];
    if (soundEnabled) {
        AVAudioPlayer* player= [self.soundplayers objectAtIndex:2];
        [player play];
    }

}
// =========================
// VIEW WILL DISAPPEAR
// =========================
-(void) viewWillDisappear:(BOOL)animated {
    // stop timer
    [self.timer invalidate];
}
// =========================
// DID RECEIVE MEMORY WARNING
// =========================
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Support
// =========================
// SOUNDS SETUP
// =========================
// populates an array that will contain references to the loaded sounds
- (void) setupSounds {
    // 0: victory
    // 1: sinking
    // 2: background music
    _soundplayers = [[NSMutableArray alloc] init];
    
    // load victory sound (when player beats a level)
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"ff6_victory" ofType:@"mp3"];
    NSURL* filePath = [NSURL fileURLWithPath:soundPath isDirectory:false];
    AVAudioPlayer* audioplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    [audioplayer prepareToPlay];
    [self.soundplayers addObject:audioplayer];
    
    // load sinking sound (when player restarts a level)
    soundPath = [[NSBundle mainBundle] pathForResource:@"warcraft2_humanshipsinking" ofType:@"mp3"];
    filePath = [NSURL fileURLWithPath:soundPath isDirectory:false];
    audioplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    [audioplayer prepareToPlay];
    [self.soundplayers addObject:audioplayer];
    
    // load background music
    soundPath = [[NSBundle mainBundle] pathForResource:@"wii_mii_channel" ofType:@"mp3"];
    filePath = [NSURL fileURLWithPath:soundPath isDirectory:false];
    audioplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    audioplayer.numberOfLoops = -1;
    [audioplayer prepareToPlay];
    [self.soundplayers addObject:audioplayer];
}

// =========================
// START TIMER
// =========================
// begins the timer that keeps track how long the player is taking to complete a level
- (void) startTimer {
    // run updateTimeLabel function every second
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimeLabel) userInfo:nil repeats:YES];
}

// =========================
// TIME TO STRING
// =========================
// converts number of seconds to minutes and seconds
// outputs as a string (e.g. 8:24)
- (NSString *) timeToString:(NSInteger) s {
    NSInteger minutes = s / 60;
    NSInteger seconds = s % 60;
    
    if (seconds < 10) {
        return [NSString stringWithFormat:@"%d:0%d", minutes, seconds];
    }
    else {
        return [NSString stringWithFormat:@"%d:%d", minutes, seconds];
    }
}


#pragma mark - Button Presses
// =========================
// restartPressed
// =========================
// handles action when user clicks restart button
- (IBAction)restartPressed {
    // present user with a pop-up to confirm action
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restart?"
                                                    message:@"Are you sure you want to restart?"
                                                   delegate:self // delegate set to self => self will get a call back - need to implement delegate
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Yes",nil];
    [alert setTag:1]; // identifier for restartPressed alert
    [alert show];
}

// =========================
// alert view delegate
// =========================
// delegate of alert view needs to implement UIAlertViewDelegate protocol
// response to when user interacts with alert pop-up
- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // restart button pressed
    if (alertView.tag == 1) {
        // cancel
        if (buttonIndex == 0) {
        }
        // restart
        else if (buttonIndex != alertView.cancelButtonIndex) {
            [self restart];
        }
    }
    // game completed
    else if (alertView.tag == 2) {
        // OK
        if (buttonIndex == 0) {
            [self cleanupGame];
        }
    }
}


#pragma mark - Board Grid Events

// =========================
// tilePressed
// =========================
// called in CustomCollectionView's touchesBegan (when user touches a CustomCollectionView)
// updates value of tile that user touched
- (void) tilePressed:(id)sender {
    UIView* contentView = [sender superview]; // sender = UIButton
    GameTile* cell = (GameTile *)[contentView superview];
    
    if (![self.brain isTileHintAtX:cell.column Y:cell.row]) {
        self.touchStarter = cell;
        
        NSInteger new_value = [self.brain updateTileValueAtX:cell.column Y:cell.row];
        [self updateTileImage:cell withValue:new_value];
        
        [self checkMove];
    }
}
// =========================
// tilePressedDrag
// =========================
// called in CustomCollectionView's touchesMoved (when user drags over CustomCollectionView)
- (void) tilePressedDragAtPoint:(CGPoint)point {
    NSInteger cell_size = (self.board_layout.frame.size.height / (self.brain.board_size+1));
    NSInteger xIndex = point.x / cell_size;
    NSInteger yIndex = point.y / cell_size;
    
    // if indexed cell is in game_tiles area
    // Note: the -1 is to account for goal_row being the first row
    if (xIndex < self.brain.board_size && yIndex-1 >= 0 && yIndex-1 < self.brain.board_size) {
        GameTile* cell = [[self.game_tiles objectAtIndex:xIndex] objectAtIndex:yIndex-1];

        NSInteger start_value = [self.brain getTileValueAtX:_touchStarter.column Y:_touchStarter.row];
        NSInteger current_value = [self.brain getTileValueAtX:cell.column Y:cell.row];
        if (![self.brain isTileHintAtX:cell.column Y:cell.row] &&
            _touchStarter != cell &&
            start_value != current_value) {
            
            NSInteger new_value;
            if (start_value == WATER && current_value == EMPTY) {
                new_value = WATER;
            }
            else if (start_value == SHIP && current_value == EMPTY) {
                new_value = SHIP;
            }
            else if (start_value == EMPTY) {
                new_value = EMPTY;
            }
            else {
                new_value = current_value;
            }
            
            if (new_value != current_value) {
                [self.brain setTileValueAtX:cell.column Y:cell.row withValue:new_value];
                [self updateTileImage:cell withValue:new_value];
                [self checkMove];
            }
        }
        
        
    }
}
// =========================
// tilePressedEnd
// =========================
// called in CustomCollectionView's touchesEnded (when user lifts finger after dragging over CustomCollectionView)
// clears out touchStarter (which kept track of which tile the drag action started on)
- (void) tilePressedDragEnd {
    self.touchStarter = nil;
}

// =========================
// CHECK MOVE
// =========================
// check how a new tile value changes the state of the board
- (void)checkMove {
    BOOL completed;
    NSInteger BOARD_SIZE = [self.brain board_size];
    
    // CHECK IF MOVE IS VALID OR IF GAME IS COMPLETED
    NSMutableArray* collided = [self.brain checkBoardState];
    completed = [self.brain complete_flag];
    
    /*
     NSLog(@"BOARD STATE");
     for (int i = 0; i < BOARD_SIZE; i++) {
     NSString* string = [[NSString alloc] init];
     for (int j = 0; j < BOARD_SIZE; j++) {
     string = [NSString stringWithFormat:@"%@ %d", string, [self.brain getTileValueAtX:j Y:i]];
     }
     NSLog(@"%@", string);
     }
     */
    
    // SET GOAL COLORS
    for (int i = 0; i < BOARD_SIZE; i++) {
        NSInteger row_count = 0;
        NSInteger col_count = 0;
        for (int j = 0; j < BOARD_SIZE; j++) {
            if ([self.brain getTileValueAtX:i Y:j] == SHIP) { col_count++; }
            if ([self.brain getTileValueAtX:j Y:i] == SHIP) { row_count++; }
        }
        
        // not enough ships in row/column
        GameTile* cell = [self.goal_column_tiles objectAtIndex:i];
        NSInteger row_goal = [[self.brain.goal_column objectAtIndex:i] intValue];
        if (row_count > row_goal) {
            [cell.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        else if (row_count != row_goal) {
            [cell.button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        else {
            [cell.button setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.3] forState:UIControlStateNormal];
        }
        
        cell = [self.goal_row_tiles objectAtIndex:i];
        NSInteger col_goal = [[self.brain.goal_row objectAtIndex:i] intValue];
        if (col_count > col_goal) {
            [cell.button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
        else if (col_count != col_goal) {
            [cell.button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        else {
            [cell.button setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.3] forState:UIControlStateNormal];
        }
        
    }
    
    // SET COLLIDED COLORS
    for (int i = 0; i < BOARD_SIZE; i++) {
        for (int j = 0; j < BOARD_SIZE; j++) {
            NSNumber* value = [[collided objectAtIndex:i] objectAtIndex:j];
            if ([value intValue] == 1) {
                GameTile* tile = [[self.game_tiles objectAtIndex:i] objectAtIndex:j];
                if ([self.brain isTileHintAtX:i Y:j]) {
                    [tile.button setImage:[UIImage imageNamed:@"error_hint.png"] forState:UIControlStateNormal];
                }
                else {
                    [tile.button setImage:[UIImage imageNamed:@"error.png"] forState:UIControlStateNormal];
                }
            }
            else if ([self.brain getTileValueAtX:i Y:j] == SHIP) {
                GameTile* tile = [[self.game_tiles objectAtIndex:i] objectAtIndex:j];
                if ([self.brain isTileHintAtX:i Y:j]) {
                    [tile.button setImage:[UIImage imageNamed:@"ship_hint.png"] forState:UIControlStateNormal];
                }
                else {
                    [tile.button setImage:[UIImage imageNamed:@"ship.png"] forState:UIControlStateNormal];
                }
            }
        }
    }
    
    if (completed == true) { [self gameCompleted]; }
    

    //NSLog(@"Pressed %d", indexPath.item);
    //NSLog(@"SELECT %d, %d: %d", cell.column, cell.row, new_value);
}

// =========================
// GAME COMPLETED
// =========================
- (void) gameCompleted {
    // stop timer
    [self.timer invalidate];
    
    BOOL newhighscore = [self.brain checkScore:self.time];
    
    // stop background music, play victory song
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    BOOL soundEnabled = [settings boolForKey:@"soundEnabled"];
    if (soundEnabled) {
        AVAudioPlayer* player= [self.soundplayers objectAtIndex:2];
        [player stop];
        player= [self.soundplayers objectAtIndex:0];
        [player play];
    }
    
    UIAlertView *alert;
    if (newhighscore) {
        alert = [[UIAlertView alloc] initWithTitle:@"Level Complete"
                                           message:@"You have a new high score!"
                                          delegate:self // delegate set to self => self will get a call back - need to implement delegate
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    }
    else {
        alert = [[UIAlertView alloc] initWithTitle:@"Level Complete"
                                           message:@"You completed the level!"
                                          delegate:self // delegate set to self => self will get a call back - need to implement delegate
                                 cancelButtonTitle:@"OK"
                                 otherButtonTitles:nil];
    }
    
    [alert setTag:2]; // identifier for gameCompleted alert
    [alert show];
}

// =========================
// CLEANUP GAME
// =========================
- (void) cleanupGame {
    // go back to level selection screen
    [self.navigationController popViewControllerAnimated:true];
}


// =========================
// RESTART
// =========================
// reset the game board
- (void) restart {
    // play sinking ship sound
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    BOOL soundEnabled = [settings boolForKey:@"soundEnabled"];
    if (soundEnabled) {
        AVAudioPlayer* player = [self.soundplayers objectAtIndex:1];
        [player play];
    }
    
    // reset game model
    [self.brain restartBoard];
    
    // reset UI
    for (int i = 0; i < self.level.board_size; i++) {
        for (int j = 0; j < self.level.board_size; j++) {
            // reset game tiles
            if (![self.brain isTileHintAtX:i Y:j]) {
                GameTile* tile = [[self.game_tiles objectAtIndex:i] objectAtIndex:j];
                [tile.button setImage:[UIImage imageNamed:@"empty.png"] forState:UIControlStateNormal];
            }
        }
        
        // reset goal cells to original colors
        GameTile* cell = [self.goal_row_tiles objectAtIndex:i];
        if ([self.brain checkBoardColumn:i]) {
            [cell.button setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.3] forState:UIControlStateNormal];
        }
        else {
            [cell.button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        cell = [self.goal_column_tiles objectAtIndex:i];
        if ([self.brain checkBoardRow:i]) {
            [cell.button setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.3] forState:UIControlStateNormal];
        }
        else {
            [cell.button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
    }
    
    // restart time
    [self.timer invalidate];
    _time = 0;
    self.timer_label.text = @"0:00";
    [self startTimer];
}



#pragma mark - View

// =========================
// DRAW SCREEN
// =========================
- (void)drawScreen {
    // =========================
    // UICOLLECTIONVIEW PROPERTIES
    // =========================
    // set background color to white
    self.board_layout.backgroundColor = [UIColor whiteColor];
    // determine number of tiles (for use in collection view data source)
    self.tiles_count = (self.brain.board_size+1) * (self.brain.board_size+1);
    
    // =========================
    // DRAW SHIPS
    // =========================
    NSInteger shipviewpos = 90;
    for (int i = 0; i < [self.brain.ships count]; i++) {
        NSNumber* ship_type = [self.brain.ships objectAtIndex:i];
        NSNumber* ship_count = [self.brain.ship_map objectForKey:[NSString stringWithFormat:@"%@",ship_type]];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(shipviewpos, 80, 25, 25)];
        label.text = [NSString stringWithFormat:@"%@x", ship_count];
        label.font = [UIFont systemFontOfSize:13];
        [self.view addSubview:label];
        shipviewpos += 15;
        
        for (int i = 0; i < [ship_type intValue]; i++) {
            UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(shipviewpos, 87, 13, 13)];
            [image setImage:[UIImage imageNamed:@"ship.png"]];
            [self.view addSubview:image];
            shipviewpos += 13;
        }
        
        shipviewpos += 10;
    }
    
    /*
     for (id key in self.ship_map) {
     NSNumber* value = [self.ship_map objectForKey:key];
     NSLog(@"%@: %@", key, value);
     }
     */
}

// =========================
// UPDATE TILE IMAGE
// =========================
- (void)updateTileImage:(GameTile *)tile
              withValue:(NSInteger) new_value {
    if (new_value == EMPTY) {
        [tile.button setImage:[UIImage imageNamed:@"empty.png"] forState:UIControlStateNormal];
    }
    else if (new_value == WATER) {
        [tile.button setImage:[UIImage imageNamed:@"water.png"] forState:UIControlStateNormal];
    }
    else if (new_value == SHIP) {
        [tile.button setImage:[UIImage imageNamed:@"ship.png"] forState:UIControlStateNormal];
    }
    else {
        [tile.button setImage:[UIImage imageNamed:@"empty.png"] forState:UIControlStateNormal];
    }
}


// =========================
// UPDATE TIME LABEL
// =========================
- (void) updateTimeLabel {
    // increment time by one second
    self.time += 1;
    
    // display text
    self.timer_label.text = [self timeToString:self.time];
}


#pragma mark - UICollectionViewDataSource
// =========================
// UICollectionView DataSource
// =========================
// STEP 1: DETERMINE COLLECTIONVIEW SECTION
// Returns the total number of sections
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    // only have one section
    return 1;
}
// STEP 2: DETERMINE NUMBER OF CELLS IN SECTION
// Returns the number of cells to be displayed for a given section
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.tiles_count;
}
// STEP 3: LOOP THROUGH EACH CELL
// Returns the cell at a given index
// cells with tag 0: informational tile
// cells with tag 1: game tile
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"FOR %d", indexPath.item);
    
    // obtain a cell of ID "GameTileCell" (either new cell or one that can be reused)
    GameTile* cell = [cv dequeueReusableCellWithReuseIdentifier:@"GameTileCell" forIndexPath:indexPath];
    
    // set cell parameters
    NSInteger row = indexPath.item / (self.brain.board_size+1);
    NSInteger column = indexPath.item % (self.brain.board_size+1);
    
    // if first row, then set as goal_row
    if (row == 0) {
        // corner cell not used
        if (column == self.brain.board_size) {
            cell.button.userInteractionEnabled = false;
            [cell.button setTag:0];
            [cell.button setTitle:@"" forState:UIControlStateNormal];
        }
        // goal row
        else {
            cell.button.userInteractionEnabled = false; // disable touch event
            [cell.button setTag:0];
            [cell.button setTitle:[NSString stringWithFormat:@"%@", [self.brain.goal_row objectAtIndex:column]] forState:UIControlStateNormal];
            
            if ([self.brain checkBoardColumn:column]) {
                [cell.button setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.3] forState:UIControlStateNormal];
            }
            else {
                [cell.button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
            }
            
            
            [self.goal_row_tiles addObject:cell];
        }
    }
    // if last column, then set as goal_column
    else if (column == self.brain.board_size) {
        cell.button.userInteractionEnabled = false;
        [cell.button setTag:0];
        [cell.button setTitle:[NSString stringWithFormat:@"%@", [self.brain.goal_column objectAtIndex:row-1]] forState:UIControlStateNormal];
        
        if ([self.brain checkBoardRow:row-1]) {
            [cell.button setTitleColor:[UIColor colorWithWhite:0.7 alpha:0.3] forState:UIControlStateNormal];
        }
        else {
            [cell.button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        }
        
        [self.goal_column_tiles addObject:cell];
    }
    // else, set as game_tile
    else {
        cell.row = row-1;
        cell.column = column;
        [cell.button setTag:1];
        if ([self.brain isTileHintAtX:column Y:row-1]) {
            cell.button.userInteractionEnabled = false;
            if ([self.brain getTileValueAtX:column Y:row-1] == WATER) {
                [cell.button setImage:[UIImage imageNamed:@"water_hint.png"] forState:UIControlStateNormal];
            }
            else if ([self.brain getTileValueAtX:column Y:row-1] == SHIP) {
                [cell.button setImage:[UIImage imageNamed:@"ship_hint.png"] forState:UIControlStateNormal];
            }
        }
        else {
            cell.button.userInteractionEnabled = false;
            [cell.button setImage:[UIImage imageNamed:@"empty.png"] forState:UIControlStateNormal];
            //[cell.button addTarget:self action:@selector(tilePressed:) forControlEvents:UIControlEventTouchUpInside]; // set tilePressed as touch handler
        }
        
        [[self.game_tiles objectAtIndex:column] addObject:cell];
    }
    
    //NSLog(@"FOR %d, %d", cell.row, cell.column);
    
    return cell;
}
// Returns a view for either the header or footer for each section of the UICollectionView.
// “kind” = header or footer
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }
*/


#pragma mark - UICollectionViewDelegate
/*
// =========================
// UICollectionView Delegate
// =========================
// Select Item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //((GameTile *)collectionView).imageView.image = [UIImage imageNamed:@"error.png"];
    //GameTile *cell = [self.game_tiles objectAtIndex:indexPath.item];
    //cell.imageView.image = [UIImage imageNamed:@"error.png"];
    //NSLog(@"SELECT %d, %d", cell.column, cell.row);
}
// Deselect Item (if allow for multiple selection)
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"DESELECT %d", indexPath.item);
}
*/

#pragma mark - UICollectionViewDelegateFlowLayout
// =========================
// UICollectionView Delegate
// =========================
// Specify size of a cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {    
    NSInteger row = indexPath.item / (self.brain.board_size+1);
    NSInteger column = indexPath.item % (self.brain.board_size+1);
    
    // calculate size of cell based on collectionview size
    CGRect frame = [self.board_layout frame];
    NSInteger cell_size = (frame.size.height)/(self.brain.board_size+1);
    CGSize retval;
    
    // goal_row
    if (row == 0) {
        retval = CGSizeMake(cell_size, cell_size);
        // corner cell
        if (column == self.brain.board_size) {
            retval = CGSizeMake(cell_size, cell_size);
        }
    }
    // goal_column
    else if (column == self.brain.board_size) {
        retval = CGSizeMake(cell_size, cell_size);
    }
    // game_tiles
    else {
        retval = CGSizeMake(cell_size, cell_size);
    }
    //NSLog(@"ROW: %d, COL: %d, SIZE X: %f, SIZE Y: %f",row, column, retval.width, retval.height);
    //NSLog(@"WIDTH: %f HEIGHT: %f", frame.size.width, frame.size.height);

    return retval;
}
// Returns spacing between cells, headers, and footers
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end
