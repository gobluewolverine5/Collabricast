//
//  SlideshowMain.m
//  MediaCast
//
//  Created by Evan Hsu on 2/20/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "SlideshowMain.h"
#import "pictureOps.h"
#import "AppDelegate.h"
#import "PlaySlideshow.h"
#import "SettingsVC.h"

#define LEFT 0
#define MIDDLE 1
#define RIGHT 2

@interface SlideshowMain ()

@end

@implementation SlideshowMain {
    UIImage *_cast_btn;
    UIImage *_connected_cast_btn;
    pictureOps *picture_ops;
    NSMutableArray *images;
    NSMutableArray *image_files;
    int currentIndex;
}

@synthesize duration;
@synthesize imageQuality;

@synthesize deviceScannerObject;
@synthesize deviceManagerObject;
@synthesize selectedDevice;
@synthesize mediaControlChannel;
@synthesize session_id;

@synthesize middleImage;
@synthesize rightImage;
@synthesize leftImage;
@synthesize deleteButtons;

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
    
    ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initImagePicker];
    imagePicker.maximumImagesCount = 20;
    imagePicker.returnsOriginalImage = NO;
    imagePicker.imagePickerDelegate = self;

    [self presentViewController:imagePicker animated:YES completion:Nil];
    
    duration = 10;
    imageQuality = 0.7;
    
    picture_ops = [[pictureOps alloc] init];
    [picture_ops clearCache];
    
    images = [[NSMutableArray alloc]init];
    image_files = [[NSMutableArray alloc]init];
    currentIndex = 0;
    
    leftImage.contentMode = UIViewContentModeScaleAspectFit;
    middleImage.contentMode = UIViewContentModeScaleAspectFit;
    rightImage.contentMode = UIViewContentModeScaleAspectFit;
    
    /* CONFIGURE CAST BUTTON */
    _connected_cast_btn = [UIImage imageNamed:@"icon-cast-connected.png"];
    _cast_btn = [UIImage imageNamed:@"icon-cast-identified.png"];
    
    _chromecastButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [_chromecastButton addTarget:self
                          action:@selector(chooseDevice:)
                forControlEvents:UIControlEventTouchDown];
    _chromecastButton.frame = CGRectMake(0, 0, _cast_btn.size.width, _cast_btn.size.height);
    [_chromecastButton setImage:nil forState:UIControlStateNormal];
    _chromecastButton.hidden = YES;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_chromecastButton];
    [self updateButtonStates];
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toPlaySlideshow"]) {
        PlaySlideshow *play_slideshow = (PlaySlideshow *) segue.destinationViewController;
        play_slideshow.images = images;
        play_slideshow.duration = duration;
        play_slideshow.deviceScannerObject = deviceScannerObject;
        play_slideshow.deviceManagerObject = deviceManagerObject;
        play_slideshow.mediaControlChannel = mediaControlChannel;
        play_slideshow.selectedDevice = selectedDevice;
        play_slideshow.session_id = session_id;
    }
    else if ([segue.identifier isEqualToString:@"toSettings"]) {
        SettingsVC *settings_vc = (SettingsVC *) segue.destinationViewController;
        settings_vc.delegate = self;
        settings_vc.imageQuality = imageQuality;
        settings_vc.duration  = duration;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SettingsVC Delegate

-(void)sendSettingsData:(CGFloat)iQ viewDuration:(int)time
{
    imageQuality = iQ;
    duration = time;
}

#pragma mark - IBAction

- (IBAction)addImages:(id)sender
{
    if ([images count] < 20) {
        ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initImagePicker];
        imagePicker.maximumImagesCount = 20 - [images count];
        imagePicker.returnsOriginalImage = NO;
        imagePicker.imagePickerDelegate = self;
        [self presentViewController:imagePicker animated:YES completion:Nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle     :@"Error"
                              message           :@"You've reached the maximum of 20 pictures"
                              delegate          :nil
                              cancelButtonTitle :@"OK"
                              otherButtonTitles :nil];
        [alert show];
    }
}

- (IBAction)toSettings:(id)sender
{
    [self performSegueWithIdentifier:@"toSettings" sender:nil];
}

- (IBAction)playSlideshow:(id)sender
{
    if ([images count] > 0) {
        [self performSegueWithIdentifier:@"toPlaySlideshow" sender:Nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle     :@"Error"
                              message           :@"Please select images"
                              delegate          :nil
                              cancelButtonTitle :@"OK"
                              otherButtonTitles :nil];
        [alert show];
        
    }
}
- (IBAction)deleteImage:(id)sender
{

}

- (IBAction)shiftRight:(id)sender
{
    if (!(currentIndex == [images count] - 1 || [images count] == 0)) {
        currentIndex++;
        [self refreshSlideshowQueuePreview];
    }
}

- (IBAction)shiftLeft:(id)sender {
    if (!(currentIndex == 0 || [images count] == 0)) {
        currentIndex--;
        [self refreshSlideshowQueuePreview];
    }
}

- (void) refreshSlideshowQueuePreview
{
    [UIView beginAnimations:@"animate" context:nil];
    [UIView setAnimationDuration:0.2];
    if ((currentIndex - 1) >= 0 && (currentIndex - 1) <= [images count]-1) {
        [self loadImageAtIndex:(currentIndex-1) previewWindow:LEFT];
    } else {
        leftImage.image = Nil;
    }
    if ((currentIndex) >= 0 && (currentIndex) <= [images count]-1) {
        [self loadImageAtIndex:(currentIndex) previewWindow:MIDDLE];
    } else {
        middleImage.image = Nil;
    }
    if ((currentIndex + 1) >= 0 && (currentIndex + 1) <= [images count]-1) {
        [self loadImageAtIndex:(currentIndex+1) previewWindow:RIGHT];
    } else {
        rightImage.image = Nil;
    }
    [UIView commitAnimations];
}

-(void) loadImageAtIndex:(int)index previewWindow:(int)type
{
    NSLog(@"loading image");

    switch (type) {
        case LEFT:
            leftImage.image = [UIImage imageWithCGImage:((UIImage*)[image_files objectAtIndex:index]).CGImage
                                                  scale:1.0f
                                            orientation:UIImageOrientationUp];
            break;
        case MIDDLE:
            middleImage.image = [UIImage imageWithCGImage:((UIImage*)[image_files objectAtIndex:index]).CGImage
                                                  scale:1.0f
                                            orientation:UIImageOrientationUp];
            break;
        case RIGHT:
            rightImage.image = [UIImage imageWithCGImage:((UIImage*)[image_files objectAtIndex:index]).CGImage
                                                  scale:1.0f
                                            orientation:UIImageOrientationUp];
            break;
        default:
            middleImage.image = [UIImage imageWithCGImage:((UIImage*)[image_files objectAtIndex:index]).CGImage
                                                  scale:1.0f
                                            orientation:UIImageOrientationUp];
            break;
    }
}

- (UIImage *)resizeImage:(UIImage*)image newSize:(CGSize)newSize {
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGImageRef imageRef = image.CGImage;
    
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, newSize.height);
    
    CGContextConcatCTM(context, flipVertical);
    // Draw into the context; this scales the image
    CGContextDrawImage(context, newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(context);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    CGImageRelease(newImageRef);
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - ELCImagePickerControllerDelegate

- (void) elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"info: %@",info);
    CGSize size = middleImage.frame.size;
    for (int i = 0; i < [info count]; i++) {
        NSDictionary *infoDict = [info objectAtIndex:i];
        
        /*
        [image_files addObject:[self resizeImage:[UIImage imageWithData:UIImageJPEGRepresentation([picture_ops saveImage:infoDict highQuality:imageQuality], 0.1)]
                                         newSize:size]];
         */
        [image_files addObject:[UIImage imageWithData:UIImageJPEGRepresentation([picture_ops
                                                                                 saveImage:infoDict
                                                                                 highQuality:imageQuality], 0.1)]];
        //[image_files addObject:[picture_ops saveImage:infoDict]];
        [images addObject:[picture_ops returnFileName]];
    }
    [self refreshSlideshowQueuePreview];
}

- (void) elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"Canceled Image Picker");
}

/*################## CHOMECAST CODE ######################*/

#pragma mark - GCKDeviceScannerListner
- (void)deviceDidComeOnline:(GCKDevice *)device
{
    NSLog(@"Device Found: %@", [device friendlyName]);
    [self updateButtonStates];
}

- (void)deviceDidGoOffline:(GCKDevice *)device
{
    NSLog(@"Device Went Offline");
    [self updateButtonStates];
}

#pragma mark - GCKDeviceManagerDelegate
- (void)deviceManagerDidConnect:(GCKDeviceManager *)deviceManager {
    NSLog(@"connected!!");
    
    [self updateButtonStates];
    [self.deviceManagerObject launchApplication:@"549D1581"];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApp {
    
    mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    mediaControlChannel.delegate = self;
    session_id = sessionID;
    [deviceManager addChannel:mediaControlChannel];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
    NSLog(@"Received notification that device disconnected");
    
    if (error != nil) {
        [self showError:error];
    }
    
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToLaunchCastApplicationWithError:(NSError *)error {
  [self showError:error];

}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToConnectWithError:(GCKError *)error {
  [self showError:error];

}

#pragma mark - misc
- (void)showError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:NSLocalizedString(error.description, nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (selectedDevice == nil) {
        if (buttonIndex < self.deviceScannerObject.devices.count) {
            selectedDevice = self.deviceScannerObject.devices[buttonIndex];
            NSLog(@"Selecting device:%@", selectedDevice.friendlyName);
            [self connectToDevice];
        }
    } else {
        if (buttonIndex == 0) {  //Disconnect button
            NSLog(@"Disconnecting device:%@", selectedDevice.friendlyName);
            // New way of doing things: We're not going to stop the applicaton. We're just going
            // to leave it.
            [self.deviceManagerObject leaveApplication];
            // If you want to force application to stop, uncomment below
            [self.deviceManagerObject stopApplicationWithSessionID:session_id];
            [self.deviceManagerObject disconnect];
            
            [self deviceDisconnected];
            [self updateButtonStates];
            
        } else if (buttonIndex == 0) {
            // Join the existing session.
            
        }
    }
}

#pragma mark - GCK Custom Functions
- (void)connectToDevice {
    if (selectedDevice == nil)
        return;
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    self.deviceManagerObject =
    [[GCKDeviceManager alloc] initWithDevice:selectedDevice
                           clientPackageName:[info objectForKey:@"CFBundleIdentifier"]];
    
    NSLog(@"bunde id: %@", [info objectForKey:@"CFBundleIdentifier"]);
    self.deviceManagerObject.delegate = self;
    [self.deviceManagerObject connect];
}

- (void)deviceDisconnected {
  deviceManagerObject = nil;
  selectedDevice = nil;
  NSLog(@"Device disconnected");
}

- (void)updateButtonStates {
  if (self.deviceScannerObject.devices.count == 0) {
    //Hide the cast button
    [_chromecastButton setImage:_cast_btn forState:UIControlStateNormal];
    _chromecastButton.hidden = YES;
  } else {
    if (self.deviceManagerObject && self.deviceManagerObject.isConnected) {
      //Enabled state for cast button
      [_chromecastButton setImage:_connected_cast_btn forState:UIControlStateNormal];
      [_chromecastButton setTintColor:[UIColor blueColor]];
      _chromecastButton.hidden = NO;
    } else {
      //Disabled state for cast button
      [_chromecastButton setImage:_cast_btn forState:UIControlStateNormal];
      [_chromecastButton setTintColor:[UIColor grayColor]];
      _chromecastButton.hidden = NO;
    }
  }

}

- (void)chooseDevice:(id)sender {
    //Choose device
    if (selectedDevice == nil) {
        //Device Selection List
        UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Connect to Device", nil)
                                    delegate:self
                           cancelButtonTitle:nil
                      destructiveButtonTitle:nil
                           otherButtonTitles:nil];
        
        for (GCKDevice *device in self.deviceScannerObject.devices) {
            [sheet addButtonWithTitle:device.friendlyName];
        }
        
        [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        
        [sheet showInView:_chromecastButton];
    } else {
        //Already connected information
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"Casting to %@", nil),
                         selectedDevice.friendlyName];
        //NSString *mediaTitle = [mediaInformation.metadata stringForKey:kGCKMetadataKeyTitle];
        
        UIActionSheet *sheet = [[UIActionSheet alloc] init];
        sheet.title = str;
        sheet.delegate = self;
        /*
        if (mediaTitle != nil) {
            [sheet addButtonWithTitle:mediaTitle];
        }
         */
        [sheet addButtonWithTitle:@"Disconnect"];
        [sheet addButtonWithTitle:@"Cancel"];
        //sheet.destructiveButtonIndex = (mediaTitle != nil ? 1 : 0);
        //sheet.cancelButtonIndex = (mediaTitle != nil ? 2 : 1);
        
        [sheet showInView:_chromecastButton];
    }
}

/*############# END OF CHROMECAST CODE #################*/

@end
