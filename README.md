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
  - <i>Modal</i> presents another screen that isn't "connected" to the current screen (like a pop-up)
  - This [link](http://stackoverflow.com/questions/9392744/difference-between-modal-and-push-segue-in-storyboards) describes the differences fairly well
8. Repeat this for other views

### Level Selection
I then started to populate the Table View Controller. This View Controller is used to populate a list of available levels in the game. 

1. Add levels.txt to the project
    1. File -> Add Files to "Project"
    2. Select levels.txt
2. File -> New -> File -> iOS/Cocoa Touch -> <b>Objective-C Class</b>
3. Set Class to <b>LevelSelectViewController</b>
4. Set Subclass to <b>UITableViewController</b>
5. Click <b>Next</b>
6. Set Destination to your application's directory
7. Click <b>Create</b>
8. In the storyboard, select the Table View Controller
9. Select the <i>Identity</i> inspector in the right panel
10. In the <i>Custom class</i> section, set <i>Class</i> to <b>LevelSelectViewController</b>
    1. This was the class created above. The option should be available in the drop-down menu
    2. This tells this View Controller to use LevelSelectViewController
11. Load the levels.txt file by adding the following code in LevelSelectViewController.m
    1. viewDidLoad is invoked once the view controller has finished loading the view)

    ```objective-c
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
12. In MainStoryboard.storyboard, select the Prototype Cell (the lone entry in the table) in the LevelSelectViewController object. In the Identity inspector, set <i>Restoration ID</i> to some name (I picked <b>LevelCell</b>)
13. In LevelSelectViewController.m, implement the associated UITableViewController functions. 
    1. Since this class subclassed UITableViewController, the associated functions were already added to the .m file

    ```objective-c
    - (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
        // Return the number of sections
        // we only have one section/group in table
        return 1;
    }
    - (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
        // Return the number of rows in the section.
        return self.levels.count; // I stored all of the levels in an array
    }
    - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
        // this function will be called for each row in the table

        // populate table
        Level* level = [self.levels objectAtIndex:indexPath.row];
        static NSString* CellIdentifier = @"LevelCell"; // defined in StoryBoard (CustomCollectionView)
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
        // set cell label
        cell.textLabel.text = [NSString stringWithFormat:@"Board%@ (%dx%d)",level.board_id,level.board_size,level.board_size];
    
        return cell;
    }
    ```

### Game Screen
#### Storyboard
To create the game board...

1. Drag a Collection View object to a new view controller.
2. Click the prototype cell in the Collection View (the first tile), and set an Identifier in the Attributes inspector (similar to the Level Select screen). In this case, I named it <b>GameTileCell</b>
3. Create a custom class for the Collection View 
    1. File -> New -> File -> iOS/Cocoa Touch -> Objective-C Class
    2. Set <i>Class</i> to <b>CustomCollectionView</b>
    3. Set <i>Subclass</i> to <b>UICollectionView</b>
    4. Click <b>Next</b>
    5. Set destination to your application's directory
    6. Click <b>Create</b>
4. Click the Collection View object, navigate to the <i>Identity</i> inspector, and set the <i>Custom Class</i> to <b>CustomCollectionView</b>

#### Code

``` objective-c
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    // Returns the total number of sections
    // only one section
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    // Returns the number of cells to be displayed for a given section
    return self.tiles_count;
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Returns the cell at a given index
    // cells with tag 0: informational tile
    // cells with tag 1: game tile
    //NSLog(@"FOR %d", indexPath.item);

    // obtain a cell of ID "GameTileCell" (either new cell or one that can be reused)
    GameTile* cell = [cv dequeueReusableCellWithReuseIdentifier:@"GameTileCell" forIndexPath:indexPath];
    
    // set cell parameters...
    
    //NSLog(@"FOR %d, %d", cell.row, cell.column);
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout
// Specify size of a cell
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.item / (self.brain.board_size+1);
    NSInteger column = indexPath.item % (self.brain.board_size+1);

    // calculate size of cell based on collectionview size
    CGRect frame = [self.board_layout frame];
    NSInteger cellsize = (frame.size.height)/(self.brain.board_size+1);
    CGSize retval = CGSizeMake(cellsize, cellsize);
    
    //NSLog(@"ROW: %d, COL: %d, SIZE X: %f, SIZE Y: %f",row, column, retval.width, retval.height);
    //NSLog(@"WIDTH: %f HEIGHT: %f", frame.size.width, frame.size.height);
    return retval;
}
// Returns spacing between cells, headers, and footers
- (UIEdgeInsets)collectionView:
(UICollectionView*)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
```

### High Scores
I ended up using SQLite for storing high scores (an alternative would be to use Core Data, but I didn't investigate that path for enough).

1. Add the following code to load the SQL database (or create one if the database cannot be found). For my project, this code was added to the application didFinishLaunchingWithOptions function in BattleshipAppDelegate.m

    ``` objective-c
    NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); // get a list of directories that are owned by the application
    NSString* docsDir = dirPaths[0]; // assume it's in the first directory
    self.databasePath = [[NSString alloc] initWithString:[docsDir stringByAppendingPathComponent:@"scores.db"]]; // this is the expected path to where the database should live ('docsDir . "/scores.db/')
    NSFileManager *filemgr = [NSFileManager defaultManager]; // define filemanager. this is used to look up if a file exists or not
    
    // if database file doesn't exist, create it
    if ([filemgr fileExistsAtPath:self.databasePath] == NO) {
        const char* dbPath = [self.databasePath UTF8String]; // convert pathname to UTF8 String
        sqlite3* scoresDB; // stores pointer to high scores database
        
        // create a database at the specified path
        if (sqlite3_open(dbPath, &scoresDB) == SQLITE_OK) { 
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
    
    // self.databasePath will be used
    ```

2. Here's an example of using a SELECT statement. This was used in the High Scores View Controller to retrieve a list of levels that contained high scores. 

    ``` objective-c
    BattleshipAppDelegate* delegate = (BattleshipAppDelegate*) [[UIApplication sharedApplication] delegate];
    const char* dbPath = [delegate.databasePath UTF8String]; // determined above
    sqlite3* scoresDB;

    // open the database
    if (sqlite3_open(dbPath, &scoresDB) == SQLITE_OK) { 
        NSString* query = [NSString stringWithFormat:@"SELECT DISTINCT BOARD FROM SCORES ORDER BY ID ASC"];
        const char* query_stmt = [query UTF8String];
    
        // query database for all unique boards
        sqlite3_stmt* statement;
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
    ```

3. Here's an example of using a DELETE statement. This was used in the Settings View Controller to delete all the high scores from the database.

    ``` objective-c
    BattleshipAppDelegate* delegate = (BattleshipAppDelegate*) [[UIApplication sharedApplication] delegate];
    const char* dbPath = [delegate.databasePath UTF8String];
    sqlite3* scoresDB;
    
    // open high scores database
    if (sqlite3_open(dbPath, &scoresDB) == SQLITE_OK) {
        // generate command to delete all entries in database
        NSString* query = [NSString stringWithFormat:@"DELETE FROM SCORES"];
        const char* delete_stmt = [query UTF8String];
        sqlite3_stmt* statement;
    
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

1. Drag a new <b>Table View Controller</b> into the storyboard
2. Select the view controller and navigate to the <i>Attributes</i> inspector
3. Set <i>Content</i> to <b>Static Cells</b>. 
    1. This means you will define how the cells look in storyboard rather than dynamically through code (like we did in the Level Select View Controller)
4. Set <i>Sections</i> to how many logical groups of settings you want. In this case, I picked <b>2</b>.
5. You can add/remove cells from each group as you see fit. If you want to add more, drag a Table View Cell object into a particular group.
6. To customize a cell, drag objects (e.g. labels, switches) onto each cell.
7. By default, each cell is selectable (like a button). I left this behavior on the <i>Reset High Scores</i> option. However, I did not want this behavior on the Sound toggle option. Highlight the corresponding cell, navigate to the <i>Attributes</i> inspector, and set <i>Selection</i> to <b>None</b>.

#### Code
1. File -> New -> File -> iOS/Resource -> <b>Property List</b>
2. Save As <b>defaults</b>
3. Click <b>Create</b>
4. Select <b>defaults.plist</b> in <i>Project Navigator</i>
5. Right-click <b>Root</b>
6. Click <b>Add Row</b>
7. Name the property (e.g. <b>soundEnabled</b>)
8. Set the property type (e.g. <b>Boolean</b>)
9. Set the default value (e.g. <b>YES</b>)
10. In BattleshipAppDelegate.m, add the following statement to load the defaults.plist file once the application has finished loading.
    
    ``` objective-c
    - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        //...
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]]];
        //...
    }
    ```
    
11. To access these values...
    
    ``` objective-c
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    BOOL soundEnabled = [settings boolForKey:@"soundEnabled"];
    ```

12. To change a value...

    ``` objective-c
    NSUserDefaults* settings = [NSUserDefaults standardUserDefaults];
    [settings setBool:true forKey:@"soundEnabled"];
    ```

### Alerts
Alerts (pop-ups) were added to the game to confirm that a user wanted to proceed with a certain action. This was used in two places. The first was to confirm that a user wanted to reset all of the stored high scores. The second was to confirm that a user wanted to reset his/her progress on a current level. 

1. To present the user with an alert, the following code was invoked after a user tapped a button

    ```objective-c
    - (void)showAlert {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Reset High Score?"
            message:@"Are you sure you want to reset high scores?"
            delegate:self // delegate set to self => this view controller will get a callback - need to implement the callback (see alertView didDismissWithButtonIndex)
            cancelButtonTitle:@"Cancel"
            otherButtonTitles:@"Yes",nil]; // could add more buttons after "Yes". List of buttons ends in "nil".
        [alert setTag:1]; // alert ID
        [alert show];
    }
    ```
    
2. To react to the user's response to the pop-up, the following function was added
    ```objective-c
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
To add sounds to the game...

1. File -> Add Files to "Project"
    2. Select an mp3 file (in this case, I added ff6_victory.mp3)
2. Add the following code...

    ```objective-c
    // load sounds
    NSString* soundPath = [[NSBundle mainBundle] pathForResource:@"ff6_victory" ofType:@"mp3"];
    NSURL* filePath = [NSURL fileURLWithPath:soundPath isDirectory:false];
    AVAudioPlayer* audioplayer = [[AVAudioPlayer alloc] initWithContentsOfURL:filePath error:nil];
    [audioplayer prepareToPlay];
    [self.soundplayers addObject:audioplayer]; // all my sounds were added to this array
    
    // play sound
    audioplayer = [self.soundplayers objectAtIndex:0];
    [audioplayer play];
    
    // stop sound
    audioplayer = [self.soundplayers objectAtIndex:0];
    [audioplayer stop];
    ```
