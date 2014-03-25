//
//  RearMenu.m
//  MediaCast
//
//  Created by Evan Hsu on 3/24/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "RearMenu.h"
#import "SWRevealViewController.h"
#import "BrushSettings.h"
#import "PictureCast.h"

@implementation customCell
@end

@interface RearMenu ()

@end

@implementation RearMenu

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    // configure the destination view controller:
    /*
    if ( [segue.destinationViewController isKindOfClass: [ColorViewController class]] &&
        [sender isKindOfClass:[UITableViewCell class]] )
    {
        UILabel* c = [(SWUITableViewCell *)sender label];
        ColorViewController* cvc = segue.destinationViewController;
        
        cvc.color = c.textColor;
        cvc.text = c.text;
    }
     */

    // configure the segue.
    if ( [segue isKindOfClass: [SWRevealViewControllerSegue class]] )
    {
        SWRevealViewControllerSegue* rvcs = (SWRevealViewControllerSegue*) segue;
        
        SWRevealViewController* rvc = self.revealViewController;
        NSAssert( rvc != nil, @"oops! must have a revealViewController" );
        
        NSAssert( [rvc.frontViewController isKindOfClass: [UINavigationController class]], @"oops!  for this segue we want a permanent navigation controller in the front!" );

        rvcs.performBlock = ^(SWRevealViewControllerSegue* rvc_segue, UIViewController* svc, UIViewController* dvc)
        {
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
            UINavigationController *sbnc = [storyboard instantiateViewControllerWithIdentifier:@"mainNav"];
            [sbnc popToRootViewControllerAnimated:NO];
            [sbnc pushViewController:dvc animated:YES];
            //UINavigationController* nc = [[UINavigationController alloc] initWithRootViewController:dvc];
            //nc.navigationBar.barTintColor   = [UIColor colorWithRed:35.0/255.0 green:54.0/255.0 blue:69.0/255.0 alpha:1];
            [sbnc.navigationBar setTintColor:[UIColor colorWithRed:0.0/255.0 green:222.0/255.0 blue:242.0/255.0 alpha:1]];
            if ([segue.destinationViewController isKindOfClass:[PictureCast class]]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Storyboard" bundle:nil];
                BrushSettings *brushSettings = [storyboard instantiateViewControllerWithIdentifier:@"brushSettings"];
                [rvc setRightViewController:brushSettings];
            } else {
                [rvc setRightViewController:nil];
            }
            [rvc pushFrontViewController:sbnc animated:YES];
            
        };
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Configure the cell...
    static NSString *CellIdentifier = @"Cell";

    switch ( indexPath.row )
    {
        case 0:
            CellIdentifier = @"home";
            break;
        case 1:
            CellIdentifier = @"pictureCast";
            break;
            
        case 2:
            CellIdentifier = @"slideshowCast";
            break;

        case 3:
            CellIdentifier = @"joinSlideshow";
            break;
    }

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier];
    
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
