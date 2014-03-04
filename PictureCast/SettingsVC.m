//
//  SettingsVC.m
//  MediaCast
//
//  Created by Evan Hsu on 2/28/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "SettingsVC.h"
#import "SlideshowMain.h"

@interface SettingsVC ()

@end

@implementation SettingsVC

@synthesize delegate;

@synthesize duration;
@synthesize imageQuality;

@synthesize qualitySlider;
@synthesize durationStepper;
@synthesize durationIndicator;
@synthesize settingsTable;
@synthesize cellOne;
@synthesize cellTwo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    settingsTable.delegate = self;
    settingsTable.dataSource = self;
    [settingsTable reloadData];
    durationIndicator.text = [NSString stringWithFormat:@"%i", duration];
    durationStepper.value = (double) duration;
    qualitySlider.value = imageQuality;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [delegate sendSettingsData:imageQuality viewDuration:duration];
}

- (IBAction)stepperPressed:(id)sender
{
    duration = (int) durationStepper.value;
    durationIndicator.text = [NSString stringWithFormat:@"%i", duration];
}

- (IBAction)sliderChanged:(id)sender
{
    imageQuality = qualitySlider.value;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Slideshow Duration";
    } else {
        return @"Image Quality";
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *CellIdOne = @"CellOne";
    static NSString *CellIdTwo = @"CellTwo";
    UITableViewCell *cell;
    NSLog(@"Hi");
    
    if (indexPath.section == 0) {
        cell = cellOne;
    }
    else {
        cell = cellTwo;
    }
    return cell;
}

@end
