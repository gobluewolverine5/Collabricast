//
//  SettingsVC.h
//  MediaCast
//
//  Created by Evan Hsu on 2/28/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol sendSettings <NSObject>

-(void)sendSettingsData:(CGFloat)iQ viewDuration:(int)time;

@end
@interface SettingsVC : UIViewController <
    UITableViewDataSource,
    UITableViewDelegate
>

@property (nonatomic, assign) id delegate;

@property (nonatomic) int duration;
@property (nonatomic) CGFloat imageQuality;

@property (strong, nonatomic) IBOutlet UISlider *qualitySlider;
@property (strong, nonatomic) IBOutlet UIStepper *durationStepper;
@property (strong, nonatomic) IBOutlet UILabel *durationIndicator;
@property (strong, nonatomic) IBOutlet UITableView *settingsTable;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellOne;
@property (strong, nonatomic) IBOutlet UITableViewCell *cellTwo;

- (IBAction)stepperPressed:(id)sender;
- (IBAction)sliderChanged:(id)sender;

@end
