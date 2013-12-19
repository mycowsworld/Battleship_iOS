//
//  HighScoreViewController.h
//  Battleship
//
//  Created by Michael Li on 4/10/13.
//  Copyright (c) 2013 Michael Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HighScoreViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIPickerView *pickerView; // select which level's high score to view
@property (weak, nonatomic) IBOutlet UILabel *score1; // text of the top score
@property (weak, nonatomic) IBOutlet UILabel *score2; // text of the 2nd best score
@property (weak, nonatomic) IBOutlet UILabel *score3; // text of the 3rd best score

@end
