//
//  SlideshowMain.h
//  MediaCast
//
//  Created by Evan Hsu on 2/20/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "PhotoPickerViewController.h"

@interface SlideshowMain : UIViewController
<
    GCKDeviceManagerDelegate,
    GCKDeviceScannerListener,
    GCKMediaControlChannelDelegate,
    UINavigationControllerDelegate,
    UIActionSheetDelegate,
    UINavigationControllerDelegate,
    UIScrollViewDelegate,
    MFMailComposeViewControllerDelegate,
    MCNearbyServiceAdvertiserDelegate,
    MCSessionDelegate,
    UIAlertViewDelegate,
    PhotoPickerViewControllerDelegate
>

@property (nonatomic) int duration;
@property (nonatomic) CGFloat imageQuality;

@property (nonatomic, assign) GCKDeviceScanner *deviceScannerObject;
@property (nonatomic, assign) GCKDeviceManager *deviceManagerObject;
@property (nonatomic, assign) GCKDevice *selectedDevice;
@property (nonatomic, assign) GCKMediaControlChannel *mediaControlChannel;
@property (nonatomic, assign) NSString *session_id;
@property (nonatomic, assign) UIButton *chromecastButton;

@property (strong, nonatomic) IBOutlet UIImageView *middleImage;
@property (strong, nonatomic) IBOutlet UIImageView *rightImage;
@property (strong, nonatomic) IBOutlet UIImageView *leftImage;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButtons;

@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCPeerID *localPeerID;
@property (strong, nonatomic) MCSession *session;
@property (nonatomic) NSMutableDictionary *peerHostLookup;

@property (assign, nonatomic) IBOutlet UIBarButtonItem *menuButton;

- (IBAction)addImages:(id)sender;
- (IBAction)toSettings:(id)sender;
- (IBAction)playSlideshow:(id)sender;
- (IBAction)deleteImage:(id)sender;
- (IBAction)shiftRight:(id)sender;
- (IBAction)shiftLeft:(id)sender;
- (IBAction)shareSlides:(id)sender;
- (IBAction)toSlideshowReorder:(id)sender;

@end
