//
//  MainViewController.h
//  PictureCast
//
//  Created by Evan Hsu on 2/9/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>

@interface PictureCast : UIViewController<GCKDeviceManagerDelegate,
                                                 GCKDeviceScannerListener,
                                                 GCKMediaControlChannelDelegate,
                                                 UINavigationControllerDelegate,
                                                 UIImagePickerControllerDelegate,

                                                 UIActionSheetDelegate>

@property (nonatomic, retain) GCKDeviceScanner *deviceScannerObject;
@property (nonatomic, retain) GCKDeviceManager *deviceManagerObject;
@property (nonatomic, retain) GCKMediaControlChannel *mediaControlChannel;
@property (nonatomic, retain) GCKDevice *selectedDevice;
@property (nonatomic, retain) NSString *session_id;
@property (nonatomic, retain) UIButton *chromecastButton;
@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;

- (IBAction)castImage:(id)sender;
- (IBAction)selectImage:(id)sender;

@end
