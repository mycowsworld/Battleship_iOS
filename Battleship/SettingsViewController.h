//
//  SettingsViewController.h
//  Battleship
//
//  Created by Michael Li on 4/8/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *sound_switch;

// =========================
// CONSTRUCTOR
// =========================
- (IBAction)soundSettingChanged;

@end
