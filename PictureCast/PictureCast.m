//
//  MainViewController.m
//  PictureCast
//
//  Created by Evan Hsu on 2/9/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "PictureCast.h"
#import "AppDelegate.h"
#import "pictureOps.h"
#import <GoogleCast/GoogleCast.h>
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface PictureCast ()

@end

@implementation PictureCast {
    UIImage *_cast_btn;
    UIImage *_connected_cast_btn;
    pictureOps *picture_ops;
}

@synthesize deviceScannerObject;
@synthesize deviceManagerObject;
@synthesize imagePreview;
@synthesize selectedDevice;
@synthesize mediaControlChannel;
@synthesize session_id;


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
    
    NSLog(@"view did load");
   
    picture_ops = [[pictureOps alloc]init];
    
    /* PRESENT UIIMAGE PICKER CONTROLLER FIRST */
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [self presentViewController:imagePicker animated:YES completion:NULL];

    /* CONFIGURE CAST BUTTON */
    _connected_cast_btn = [UIImage imageNamed:@"icon-cast-connected.png"];
    _cast_btn = [UIImage imageNamed:@"icon-cast-identified.png"];
    
    imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*################ CHROME CAST CODE ###################*/

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

#pragma mark - GCKDeviceManagerDelegate
- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApp {
    
    mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    mediaControlChannel.delegate = self;
    session_id = sessionID;
    [deviceManager addChannel:mediaControlChannel];
}

#pragma mark - Device Manager delegate
- (void)deviceManager:(GCKDeviceManager *)deviceManager didDisconnectWithError:(GCKError *)error {
    NSLog(@"Received notification that device disconnected");
    
    if (error != nil) {
        [self showError:error];
    }
    
}

#pragma mark - Device Manager Did Fail to Launch
- (void)deviceManager:(GCKDeviceManager *)deviceManager
    didFailToLaunchCastApplicationWithError:(NSError *)error {
  [self showError:error];

}

#pragma mark - Device Manager Did Fail to Connect With Error
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
            
            [self.navigationController popViewControllerAnimated:YES];
            
        } else if (buttonIndex == 0) {
            // Join the existing session.
            
        }
    }
}

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


/*############### END OF CHROMECAST CODE ################*/

- (IBAction)castImage:(id)sender
{
    [self castCurrentImage:[picture_ops returnFileName]];
}

- (IBAction)selectImage:(id)sender
{
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    
    [self presentViewController:imagePicker animated:YES completion:NULL];
}

#pragma mark - Image Picker delegate
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    if ([picture_ops clearCache]) {
        NSLog(@"Cached Succesfully cleared");
    } else {
        NSLog(@"Error clearing cached");
    }
    imagePreview.image = [picture_ops saveImage:info];
    
    [self castCurrentImage:[picture_ops returnFileName]];
}

- (void) castCurrentImage:(NSString*)filename
{
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc]init];
  
    UInt16 port_number = [(AppDelegate *)[[UIApplication sharedApplication]delegate]port_number];
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://%@:%hu/%@",
                                                                        [self getIPAddress], port_number, filename]];
    NSLog(@"Absolute url: %@", [url absoluteString]);
    GCKImage *gck_image = [[GCKImage alloc]initWithURL:url
                                                 width:100
                                                height:100];
    
    [metadata addImage:gck_image];
    
    GCKMediaInformation *mediaInformation = [[GCKMediaInformation alloc] initWithContentID:[url absoluteString]
                                                                                streamType:GCKMediaStreamTypeNone
                                                                               contentType:@"image/jpeg"
                                                                                  metadata:metadata
                                                                            streamDuration:123
                                                                                customData:nil];
    if ([mediaControlChannel loadMedia:mediaInformation
                              autoplay:YES playPosition:0] == kGCKInvalidRequestID) {
        NSLog(@"error loading media");
    }
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
@end
