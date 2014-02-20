//
//  MainViewController.h
//  PictureCast
//
//  Created by Evan Hsu on 2/9/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleCast/GoogleCast.h>

@interface PictureCast : UIViewController
<
    GCKDeviceManagerDelegate,
    GCKDeviceScannerListener,
    GCKMediaControlChannelDelegate,
    UINavigationControllerDelegate,
    UIImagePickerControllerDelegate,
    UIActionSheetDelegate,
    UIGestureRecognizerDelegate
>
{
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat brush;
    CGFloat opacity;
    int Mode;
    BOOL mouseSwiped;
}

@property (nonatomic, retain) GCKDeviceScanner *deviceScannerObject;
@property (nonatomic, retain) GCKDeviceManager *deviceManagerObject;
@property (nonatomic, retain) GCKMediaControlChannel *mediaControlChannel;
@property (nonatomic, retain) GCKDevice *selectedDevice;
@property (nonatomic, retain) NSString *session_id;
@property (nonatomic, retain) UIButton *chromecastButton;
@property (strong, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;
@property (strong, nonatomic) IBOutlet UIImageView *imageDrawingProgress;
@property (strong, nonatomic) IBOutlet UIImageView *imageDrawing;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *drawModeButton;

- (IBAction)castImage:(id)sender;
- (IBAction)selectImage:(id)sender;
- (IBAction)drawMode:(id)sender;

- (void) castCurrentImage:(NSString *)filename;
- (NSString *)getIPAddress;

@end
