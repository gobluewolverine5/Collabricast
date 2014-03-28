//
//  PlaySlideshow.h
//  MediaCast
//
//  Created by Evan Hsu on 2/20/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>

@interface PlaySlideshow : UIViewController
<
    GCKDeviceManagerDelegate,
    GCKDeviceScannerListener,
    GCKMediaControlChannelDelegate,
    UINavigationControllerDelegate,
    UIActionSheetDelegate
>

@property (nonatomic, retain) GCKDeviceScanner *deviceScannerObject;
@property (nonatomic, retain) GCKDeviceManager *deviceManagerObject;
@property (nonatomic, retain) GCKDevice *selectedDevice;
@property (nonatomic, retain) GCKMediaControlChannel *mediaControlChannel;
@property (nonatomic, retain) NSString *session_id;
@property (nonatomic, retain) UIButton *chromecastButton;

@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *image_files;
@property (nonatomic) int duration;

@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *previousButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *playButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *pauseButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *nextButton;

- (IBAction)goToPrevious:(id)sender;
- (IBAction)goToNext:(id)sender;
- (IBAction)playSlideshow:(id)sender;
- (IBAction)pauseSlideshow:(id)sender;
@end
