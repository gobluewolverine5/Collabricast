//
//  BrushSettings.h
//  MediaCast
//
//  Created by Evan Hsu on 3/13/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BrushSettingsDelegate;

@interface BrushSettings : UIViewController

@property (weak) id <BrushSettingsDelegate> delegate;

@property (strong, nonatomic) IBOutlet UISlider *brushSlider;
@property (strong, nonatomic) IBOutlet UIImageView *selectedColor;

- (IBAction)colorSelect:(UIButton*)sender;
- (IBAction)sizeChanged:(id)sender;

- (void) obtainBrush:(CGFloat) brush;
- (void) obtainOpacity:(CGFloat) opacity;
- (void) obtainRGB:(CGFloat) Red Bl:(CGFloat) Blue Gr:(CGFloat) Green;
- (void) obtainColor:(int) mode;

@end

@protocol BrushSettingsDelegate <NSObject>

@required

-(void)dissmissPop:(CGFloat)Opacity B:(CGFloat)Brush
                 R:(CGFloat)Red     Bl:(CGFloat)Blue
                Gr:(CGFloat)Green   Color:(int)mode;


@end
