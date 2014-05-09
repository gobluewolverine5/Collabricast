//
//  BrushSettings.m
//  MediaCast
//
//  Created by Evan Hsu on 3/13/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "BrushSettings.h"

@interface BrushSettings ()

@end

@implementation BrushSettings {
    CGFloat insideBrush;
    CGFloat insideOpacity;
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    int     color_mode;
}

@synthesize delegate;
@synthesize brushSlider;
@synthesize selectedColor;

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
    
    red     = 0.0 / 255.0;
    green   = 0.0 / 255.0;
    blue    = 0.0 / 255.0;
    insideBrush   = 3.0;
    insideOpacity = 1.0;
    color_mode    = 0;
    [brushSlider setValue:(insideBrush/10.0)];
    [self obtainColor:color_mode];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [delegate dissmissPop:insideOpacity B:insideBrush R:red Bl:blue Gr:green Color:color_mode];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)colorSelect:(UIButton*)sender
{
    switch (sender.tag) {
        case 0: //Black
            red = 0.0/255.0;
            green = 0.0/255.0;
            blue = 0.0/255.0;
            [self obtainColor:0];
            break;
        case 1: //Red
            red = 255.0/255.0;
            green = 0.0/255.0;
            blue = 0.0/255.0;
            [self obtainColor:1];
            break;
        case 2: //Blue
            red = 33.0/255.0;
            green = 63.0/255.0;
            blue = 153.0/255.0;
            [self obtainColor:2];
            break;
        case 3: //Green
            red = 0.0/255.0;
            green = 161.0/255.0;
            blue = 75.0/255.0;
            [self obtainColor:3];
            break;
        case 4: //white
            red = 255.0/255.0;
            green = 255.0/255.0;
            blue = 255.0/255.0;
            [self obtainColor:4];
            break;
        case 5: //orange
            red = 241.0/255.0;
            green = 101.0/255.0;
            blue = 33.0/255.0;
            [self obtainColor:5];
            break;
        case 6: //yellow
            red = 255.0/255.0;
            green = 221.0/255.0;
            blue = 23.0/255.0;
            [self obtainColor:6];
            break;
        case 7: //purple
            red = 126.0/255.0;
            green = 63.0/255.0;
            blue = 152.0/255.0;
            [self obtainColor:7];
            break;
        default:
            break;
    }
    [delegate dissmissPop:insideOpacity B:insideBrush R:red Bl:blue Gr:green Color:color_mode];
}


- (IBAction)sizeChanged:(id)sender {
    insideBrush = 10.0 * [brushSlider value];
    [delegate dissmissPop:insideOpacity B:insideBrush R:red Bl:blue Gr:green Color:color_mode];
}

-(void)obtainBrush:(CGFloat)brush
{
    insideBrush = brush;
}

-(void)obtainOpacity:(CGFloat)opacity
{
    insideOpacity = opacity;
}

-(void)obtainRGB:(CGFloat)Red Bl:(CGFloat)Blue Gr:(CGFloat)Green
{
    red     = Red;
    blue    = Blue;
    green   = Green;
}

-(void)obtainColor:(int)mode
{
    color_mode = mode;
    switch (color_mode) {
        case 0:
            NSLog(@"Black Selected");
            selectedColor.image = [UIImage imageNamed:@"Black.png"];
            break;
        case 1:
            NSLog(@"Red Selected");
            selectedColor.image = [UIImage imageNamed:@"Red.png"];
            break;
        case 2:
            NSLog(@"Blue Selected");
            selectedColor.image = [UIImage imageNamed:@"Blue.png"];
            break;
        case 3:
            NSLog(@"Green Selected");
            selectedColor.image = [UIImage imageNamed:@"Green.png"];
            break;
        case 4:
            NSLog(@"Green Selected");
            selectedColor.image = [UIImage imageNamed:@"White.png"];
            break;
        case 5:
            NSLog(@"Green Selected");
            selectedColor.image = [UIImage imageNamed:@"Orange.png"];
            break;
        case 6:
            NSLog(@"Green Selected");
            selectedColor.image = [UIImage imageNamed:@"Yellow.png"];
            break;
        case 7:
            NSLog(@"Green Selected");
            selectedColor.image = [UIImage imageNamed:@"Purple.png"];
            break;
            
        default:
            NSLog(@"Default Selected");
            break;
    }
    
}
@end
