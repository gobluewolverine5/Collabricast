//
//  SettingsTableVC.m
//  MediaCast
//
//  Created by Evan Hsu on 3/16/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "SettingsTableVC.h"

@interface SettingsTableVC ()

@end

@implementation SettingsTableVC

@synthesize delegate;

@synthesize duration;
@synthesize imageQuality;

@synthesize qualitySlider;
@synthesize durationStepper;
@synthesize durationIndicator;
@synthesize settingsTable;
@synthesize cellOne;
@synthesize cellTwo;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    durationIndicator.text  = [NSString stringWithFormat:@"%i", duration];
    durationStepper.value   = (double) duration;
    qualitySlider.value     = imageQuality;
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
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


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 74;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"SLIDESHOW DURATION";
    } else {
        return @"IMAGE QUALITY";
    }
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGFloat dist = (section == 0) ? 20.0 : 5.0;
    UIView *headerView  = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 30)];
    UILabel *label      = [[UILabel alloc] initWithFrame:CGRectMake(10, dist, tableView.bounds.size.width - 10, 18)];
    label.text              = (section == 0) ? @"SLIDESHOW DURATION" : @"IMAGE QUALITY";
    label.textColor         = [UIColor whiteColor];
    label.backgroundColor   = [UIColor clearColor];
    [headerView addSubview:label];
    
    return headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{  
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = cellOne;
    }
    else {
        cell = cellTwo;
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
