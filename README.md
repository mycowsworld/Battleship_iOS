Battleship_iOS
==============
This is an iOS project that was done for a class. The project was to recreate the game "Classic Battleships" (see [here](http://www.freeworldgroup.com/games9/gameindex/classicbattleships.htm)) on iOS.

## Usage
After launching the game, the user is met with three options...
- New Game - presents a list of levels that can be played. Selecting a level brings the user to the game screen
- High Scores - presents a list of high scores for each level
- Settings - presents options for the user to select

In the game screen, the user can tap on a tile on the screen. The small black square is an empty tile, a blue square is a water tile, and a grey square is a ship tile. The numbers along the edges of the game screen represent the number of ship tiles in that row or column. 

The other caveat is that the ship tiles must fall under a set number of configurations. For example, a level may require one 3x1 ship, two 2x1 ships, and three 1x1 ships. These ships can be in any orientation (horizontal or vertical). Note that ships cannot touch each other, meaning that a ship must be completely surrounded by water tiles.

## Documentation
### Breakpoints
To start off, I added a breakpoint for all exceptions. This would allow errors to be picked up at the point at which they were thrown instead of catching the exception once it propogates all the way up the stack.

1. In the left panel, select the <b>Breakpoint Navigator</b>
2. In the bottom left, click the '+' sign
3. Click <b>Add Exception Breakpoint</b>.
  - A new breakpoint should appear in the Breakpoint Navigator list
4. Right-click the new item, and click <b>Edit Breakpoint</b>. Ensure that <i>Exception</i> is set to <b>All</b> and <i>Break</i> is set to <b>On Throw</b>

### Storyboard
I first began by constructing the skeleton of the storyboard.

1. In MainStoryboard.storyboard, drag a <b>Navigation Controller</b> object onto the storyboard.
2. By default, a <i>Table View Controller</i> is attached to the Navigation Controller. Delete the Table View Controller (Click -> Delete) and drag a <b>View Controller</b> onto the storyboard.
3. To link the two together, right-click the Navigation Controller. Ctrl+click the circle in the <i>root view controller</i> row, and drag to the View Controller. This establishes the View Controller as the starting point.
4. Drag a <b>Table View Controller</b> object to the storyboard. This will be used for the level selection screen.
5. Drag a <b>Button</b> object onto the first View Controller.
6. Right-click the Button. Ctrl+click the circle in the <i>action</i> row, and drag to the Table View Controller. 
7. In the resulting sub-menu, select Push.
  - <i>Push</i> "pushes" the next screen on top of the current. one. This will present the user twith a Back button to move back to the current screen
  - <i>Modal</i> presents another screen that isn't "connected" to the current screen 
8. 
5. I then added a Button object onto View Controller (the first one). Right-clicking the Button brought up a menu, and in the <i>action</i> row, I ctrl+click+dragged the corresponding circle to the Table View Controller. Performing this action results in a sub-menu of choices. <i>Push</i> "pushes" the next screen on top of the current one. This also presents the user with a Back button to move back to the current screen. <i>Modal</i> just presents another screen that isn't "connected" to the current screen (like a pop-up). This (link)[http://stackoverflow.com/questions/9392744/difference-between-modal-and-push-segue-in-storyboards] describes it fairly well. In this case, I selected Push.
5. I then repeated this for the other views that I wanted.

### Level Selection
File -> New -> File -> iOS/Cocoa Touch -> Objective-C Class
Set Class to LevelSelectViewController
Set Subclass to UITableViewController
Click Next
Set destination to working directory
Click Create
In the storyboard, select the Table View Controller that was created earlier and click the black bar below the view controller.
Select the Identity inspector in the Utilities panel (right-hand side)
In the Custom class section, set Class to the class created above (the option should be available in the drop-down menu)

2. Added levels.txt to the project
    1. File -> Add Files to "<Project>"
    2. selected levels.txt
3. In LevelSelectViewController.m, I added some functionality in the viewDidLoad function, which is invoked once the view controller has finished loading the view.
``` objective-c
-(void)viewDidLoad {
    [super viewDidLoad];

    NSString* file = [[NSBundle mainBundle] pathForResource:@"levels" ofType:@"txt"];
    NSString* fileContents = [NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil];
    NSArray* allLines = [fileContents componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];

    for (int i = 0; i < [allLines count]; i++) {
        // process text file...
    }
}
```

4. When we created this ViewController, we selected that this class was a subclass of UITableViewController, so we'll need to implement those associated functions.
    1. In MainStoryboard.storyboard, select the Prototype Cell in the Level Select View Controller object. In the Identity inspector, set Restoration ID to some name (I picked LevelCell)
    2.
``` objective-c
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections
    // only one section/group in table
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.levels.count; // I stored all of the levels in an array
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // populate table
    Level* level = [self.levels objectAtIndex:indexPath.row];
    static NSString* CellIdentifier = @"LevelCell"; // defined in StoryBoard (CustomCollectionView)
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // set cell parameters
    cell.textLabel.text = [NSString stringWithFormat:@"Board %@ (%dx%d)",level.board_id, level.board_size,level.board_size];

    return cell;
}

### Game Screen
To create the game board...
I added a Collection View object to a new view controller.
Click the prototype cell in the Collection View (the first tile), and added a Identifier in the Attributes inspector (similar to the Level Select screen). In this case, I named it GameTileCell


custom collection view
change behavior for when user interacts with this collection view (more specifically, when a user touches and drags over the game board, I wanted to send specific notifications to the BattleshipViewController)
File -> New -> File -> iOS/Cocoa Touch -> Objective-C Class
Set Class to CustomCollectionView
Set Subclass to UICollectionView
Click Next
Set destination to working directory
Click Create

clicked the collection view
in the Identity inspector, set the Custom Class to CustomCollectionView

```objective-c
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
```







### High Scores
I ended up using SQLite for storing high scores (an alternative would be to use Core Data, but I didn't investigate that path for enough).


BattlshipAppDelegate.m
``` objective-c
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

        sqlite3_close(scoresDB);
    }
    else {
        NSLog(@"Failed to open/create database");
    }
}
// else use self.databasePath

```

SELECT example
``` objective -c
BattleshipAppDelegate* delegate = (BattleshipAppDelegate*) [[UIApplication sharedApplication] delegate];
const char* dbPath = [delegate.databasePath UTF8String]; // determined above
sqlite3* scoresDB;
if (sqlite3_open(dbPath, &scoresDB) == SQLITE_OK) { // open the database
    NSString* query = [NSString stringWithFormat:@"SELECT DISTINCT BOARD FROM SCORES ORDER BY ID ASC"];
    const char* query_stmt = [query UTF8String];

    // query database for all unique boards
           if (sqlite3_prepare_v2(scoresDB, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
               // if at least one row returns
               if (sqlite3_step(statement) == SQLITE_ROW) { // step through each returned row of data
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

sqlite3_stmt* statement;
```

DELETE Example
``` objective-c
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
```


### Settings
#### Storyboard
Drag a new Table View Controller into the storyboard
Select the view controller and navigate to the Attributes inspector
Set <i>Content</i> to <i>Static Cells</i>. This means you will define how the cells look in storyboard rather than dynamically through code (like we did in the Level Select View Controller)
Set Sections to how many logical groups of settings you want. In this case, I picked 2.
You can add/remove cells from each group as you see fit. If you want to add more, drag a Table View Cell object into a particular group.
To customize a cell, drag objects (e.g. labels, switch''es) onto each cell.
By default, each cell is selectable (like a button). I left this behavior on the <i>Reset High Scores</i> option. However, I did not want this behavior on the Sound toggle option. Highlight the corresponding cell, navigate to the Attributes inspector, and set Selection to None.
#### Code
File -> New -> File -> iOS/Resource -> Property List
Save As defaults
Click Create
Select defaults.plist in Project Navigator
Right-click Root
Click Add Row
Name the property (I chose soundEnabled)
Set the property type (I chose Boolean)
Set the default value (I chose YES)

In BattleshipAppDelegate.m, I added the following statement to load the defaults.plist file once the application has finished loading. It links the settings to standardUserDefaults.
``` objective -c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //...
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]]];
    //...
}
```

To access these values...
```
NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
BOOL soundEnabled = [settings boolForKey:@"soundEnabled"];
```

To save new values programmatically...
```
NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
[settings setBool:true forKey:@"soundEnabled"];
```

### Alerts
```objective - c
- (void)showAlert {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset High Score?"
        message:@"Are you sure you want to reset high scores?"
        delegate:self // delegate set to self => this view controller will get a call back - need to implement the call back (see alertView didDismissWithButtonIndex)
        cancelButtonTitle:@"Cancel"
        otherButtonTitles:@"Yes",nil];
    [alert setTag:1]; // alert ID
    [alert show];
}


- (void)alertView:(UIAlertView*)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // tag set above
    if (alertView.tag == 1) {
        // cancel
        if (buttonIndex == 0) {
        }
        // OK
        else if (buttonIndex != alertView.cancelButtonIndex) {
            // do something
        }
    }
}
```

### Sounds
```objective-c
NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"ff6_victory" ofType:@"mp3"];
NSURL* filePath = [NSURL fileURLWithPath:soundPath isDirectory:false];
AVAudioPlayer* audioplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
[audioplayer prepareToPlay];
[self.soundplayers addObject:audioplayer];

AVAudioPlayer* player= [self.soundplayers objectAtIndex:2];
[player stop];
player= [self.soundplayers objectAtIndex:0];
[player play];

```


