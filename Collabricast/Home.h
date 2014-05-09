//
//  Home.h
//  MediaCast
//
//  Created by Evan Hsu on 3/24/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>

@interface Home : UIViewController <
    GCKDeviceManagerDelegate,
    GCKDeviceScannerListener,
    GCKMediaControlChannelDelegate,
    UINavigationControllerDelegate,
    UIActionSheetDelegate
>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) IBOutlet UIImageView *chromecast_light;
@property (strong, nonatomic) IBOutlet UILabel *chromecast_status;
/*
@property (nonatomic, retain) GCKDeviceScanner *deviceScannerObject;
@property (nonatomic, retain) GCKDeviceManager *deviceManagerObject;
@property (nonatomic, retain) GCKDevice *selectedDevice;
@property (nonatomic, retain) GCKMediaControlChannel *mediaControlChannel;
 */
@property (nonatomic, retain) UIButton *chromecastButton;

@end
