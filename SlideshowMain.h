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
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"
#import "SettingsVC.h"

@interface SlideshowMain : UIViewController
<
    GCKDeviceManagerDelegate,
    GCKDeviceScannerListener,
    GCKMediaControlChannelDelegate,
    UINavigationControllerDelegate,
    UIActionSheetDelegate,
    ELCImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    UIScrollViewDelegate,
    sendSettings,
    MFMailComposeViewControllerDelegate,
    MCNearbyServiceAdvertiserDelegate,
    MCSessionDelegate,
    UIAlertViewDelegate
>

@property (nonatomic) int duration;
@property (nonatomic) CGFloat imageQuality;

@property (nonatomic, retain) GCKDeviceScanner *deviceScannerObject;
@property (nonatomic, retain) GCKDeviceManager *deviceManagerObject;
@property (nonatomic, retain) GCKDevice *selectedDevice;
@property (nonatomic, retain) GCKMediaControlChannel *mediaControlChannel;
@property (nonatomic, retain) NSString *session_id;
@property (nonatomic, retain) UIButton *chromecastButton;

@property (strong, nonatomic) IBOutlet UIImageView *middleImage;
@property (strong, nonatomic) IBOutlet UIImageView *rightImage;
@property (strong, nonatomic) IBOutlet UIImageView *leftImage;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *deleteButtons;

@property (strong, nonatomic) MCNearbyServiceAdvertiser *advertiser;
@property (strong, nonatomic) MCPeerID *localPeerID;
@property (strong, nonatomic) MCSession *session;

- (IBAction)addImages:(id)sender;
- (IBAction)toSettings:(id)sender;
- (IBAction)playSlideshow:(id)sender;
- (IBAction)deleteImage:(id)sender;
- (IBAction)shiftRight:(id)sender;
- (IBAction)shiftLeft:(id)sender;
- (IBAction)shareSlides:(id)sender;

@end
