//
//  PlaySlideshow.m
//  MediaCast
//
//  Created by Evan Hsu on 2/20/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "PlaySlideshow.h"
#import "AppDelegate.h"
#import "RearMenu.h"
#import "SWRevealViewController.h"
#import "MultipeerRules.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface PlaySlideshow ()

@end

@implementation PlaySlideshow {
    
    UIImage *_cast_btn;
    UIImage *_connected_cast_btn;
    NSTimer *timer;
    NSTimeInterval *time_interval;
    int index;
    BOOL playing;
    RearMenu *rearMenu;
}

@synthesize deviceManagerObject;
@synthesize deviceScannerObject;
@synthesize selectedDevice;
@synthesize mediaControlChannel;
@synthesize session_id;

@synthesize imagePreview;
@synthesize previousButton;
@synthesize playButton;
@synthesize pauseButton;
@synthesize nextButton;

@synthesize images;
@synthesize duration;

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
    rearMenu = (RearMenu *) self.revealViewController.rearViewController;
    
    playing = TRUE;
    UIColor *lightblue = [UIColor colorWithRed:0 green:222 blue:242 alpha:1];
    playButton.tintColor = lightblue;
    pauseButton.tintColor = [UIColor whiteColor];
    previousButton.tintColor = [UIColor whiteColor];
    nextButton.tintColor = [UIColor whiteColor];
    imagePreview.contentMode = UIViewContentModeScaleAspectFit;
    
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
    
    [self updateButtonStates];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_chromecastButton];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:duration - 1.0
                                             target:self
                                           selector:@selector(advancePicture:)
                                           userInfo:Nil
                                            repeats:YES];
    
    index = (int) [images count] - 1;
    [self advancePicture:YES];
    [self.navigationController.navigationBar setTranslucent:NO];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    
    /* MC SESSION */
    _session.delegate = self;
    
}

-(void)viewDidAppear:(BOOL)animated
{
    rearMenu.deviceManagerObject.delegate = self;
    rearMenu.mediaControlChannel.delegate = self;
    [rearMenu.deviceScannerObject addListener:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopTimer];
    [self broadcastStopSlideshow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
- (IBAction)goToPrevious:(id)sender
{
    [self advancePicture:NO];
}

- (IBAction)goToNext:(id)sender
{
    [self advancePicture:YES];
}

- (IBAction)playSlideshow:(id)sender
{
    if (!playing) {
        UIColor *lightblue = [UIColor colorWithRed:0 green:222 blue:242 alpha:1];
        playButton.tintColor = lightblue;
        pauseButton.tintColor = [UIColor whiteColor];
        playing = !playing;
        [self startTimer];
    }
}

- (IBAction)pauseSlideshow:(id)sender {
    if (playButton) {
        UIColor *lightblue = [UIColor colorWithRed:0 green:222 blue:242 alpha:1];
        playButton.tintColor = [UIColor whiteColor];
        pauseButton.tintColor = lightblue;
        playing = !playing;
        [self stopTimer];
    }
}

#pragma mark - Slideshow

- (void) advancePicture:(BOOL)forward
{
    if (forward) {
        index = (index + 1) % [images count];
    } else {
        index = (index - 1) % [images count];
    }
    NSLog(@"index: %i", index);
    /*
    AppDelegate *app_delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *saveDirectory = [NSString stringWithFormat:@"%@/%@", [app_delegate cacheURL], [images objectAtIndex:index]];
    NSData *data = [[NSFileManager defaultManager] contentsAtPath:saveDirectory];
     */
    GCKMediaMetadata *metadata = [[GCKMediaMetadata alloc]init];
  
    NSURL *url = [[NSURL alloc]initWithString:[images objectAtIndex:index]];
    NSLog(@"Absolute url: %@", [url absoluteString]);
    GCKImage *gck_image = [[GCKImage alloc]initWithURL:url
                                                 width:100
                                                height:100];
    
    [metadata addImage:gck_image];
    
    GCKMediaInformation *mediaInformation = [[GCKMediaInformation alloc] initWithContentID:[url absoluteString]
                                                                                streamType:GCKMediaStreamTypeUnknown
                                                                               contentType:@"image/jpeg"
                                                                                  metadata:metadata
                                                                            streamDuration:123
                                                                                customData:nil];
    if ([rearMenu.mediaControlChannel loadMedia:mediaInformation
                              autoplay:YES playPosition:0] == kGCKInvalidRequestID) {
        NSLog(@"error loading media");
    }
    [self broadcastPictureUrl:[images objectAtIndex:index]
                        index:[NSNumber numberWithInt:index]];
    double delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        /*
        imagePreview.image  = [UIImage imageWithCGImage:((UIImage*)[_image_files objectAtIndex:index]).CGImage
                                                  scale:1.0f
                                            orientation:UIImageOrientationUp];
         */
        imagePreview.image = [_image_files objectAtIndex:index];
    });

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

#pragma mark - NSTimer
- (void) stopTimer
{
    [timer invalidate];
    timer = Nil;
}

- (void) startTimer
{
    timer = [NSTimer scheduledTimerWithTimeInterval:duration - 1.0
                                             target:self
                                           selector:@selector(advancePicture:)
                                           userInfo:Nil
                                            repeats:YES];
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
    [rearMenu.deviceManagerObject launchApplication:@"549D1581"];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApp {
    
    rearMenu.mediaControlChannel = [[GCKMediaControlChannel alloc] init];
    rearMenu.mediaControlChannel.delegate = self;
    rearMenu.session_id = sessionID;
    [deviceManager addChannel:rearMenu.mediaControlChannel];
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

- (void)broadcastPictureUrl:(NSString*)url index:(NSNumber *)ind
{
    NSDictionary *msgpkt = @{@"type"  : [NSNumber numberWithInt:BROADCAST_PICTURE],
                             @"url"   : url,
                             @"index" : ind};
    NSData *data = [NSJSONSerialization dataWithJSONObject:msgpkt options:0 error:Nil];
    [_session sendData:data toPeers:_peers withMode:MCSessionSendDataReliable error:Nil];
}

- (void)broadcastStopSlideshow
{
    NSDictionary *msgpkt = @{@"type" : [NSNumber numberWithInt:STOP_SLIDESHOW]};
    NSData *data = [NSJSONSerialization dataWithJSONObject:msgpkt options:0 error:nil];
    [_session sendData:data toPeers:_peers withMode:MCSessionSendDataReliable error:Nil];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (rearMenu.selectedDevice == nil) {
        if (buttonIndex < rearMenu.deviceScannerObject.devices.count) {
            rearMenu.selectedDevice = rearMenu.deviceScannerObject.devices[buttonIndex];
            NSLog(@"Selecting device:%@", rearMenu.selectedDevice.friendlyName);
            [self connectToDevice];
        }
    } else {
        if (buttonIndex == 0) {  //Disconnect button
            NSLog(@"Disconnecting device:%@", rearMenu.selectedDevice.friendlyName);
            // New way of doing things: We're not going to stop the applicaton. We're just going
            // to leave it.
            [rearMenu.deviceManagerObject leaveApplication];
            // If you want to force application to stop, uncomment below
            [rearMenu.deviceManagerObject stopApplicationWithSessionID:rearMenu.session_id];
            [rearMenu.deviceManagerObject disconnect];
            
            [self deviceDisconnected];
            [self updateButtonStates];
            
        } else if (buttonIndex == 0) {
            // Join the existing session.
            
        }
    }
}

#pragma mark - GCK Custom Functions
- (void)connectToDevice {
    if (rearMenu.selectedDevice == nil)
        return;
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    rearMenu.deviceManagerObject =
    [[GCKDeviceManager alloc] initWithDevice:rearMenu.selectedDevice
                           clientPackageName:[info objectForKey:@"CFBundleIdentifier"]];
    
    NSLog(@"bunde id: %@", [info objectForKey:@"CFBundleIdentifier"]);
    rearMenu.deviceManagerObject.delegate = self;
    [rearMenu.deviceManagerObject connect];
}

- (void)deviceDisconnected {
  rearMenu.deviceManagerObject  = nil;
  rearMenu.selectedDevice       = nil;
  NSLog(@"Device disconnected");
}

- (void)updateButtonStates {
  if (rearMenu.deviceScannerObject.devices.count == 0) {
    //Hide the cast button
    [_chromecastButton setImage:_cast_btn forState:UIControlStateNormal];
    _chromecastButton.hidden = YES;
  } else {
    if (rearMenu.deviceManagerObject && rearMenu.deviceManagerObject.isConnected) {
      //Enabled state for cast button
      [_chromecastButton setImage:_connected_cast_btn forState:UIControlStateNormal];
      [_chromecastButton setTintColor:[UIColor colorWithRed:199.0/255.0 green:244.0/255.0 blue:100.0/255.0 alpha:1]];
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
    if (rearMenu.selectedDevice == nil) {
        //Device Selection List
        UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Connect to Device", nil)
                                    delegate:self
                           cancelButtonTitle:nil
                      destructiveButtonTitle:nil
                           otherButtonTitles:nil];
        
        for (GCKDevice *device in rearMenu.deviceScannerObject.devices) {
            [sheet addButtonWithTitle:device.friendlyName];
        }
        
        [sheet addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
        sheet.cancelButtonIndex = sheet.numberOfButtons - 1;
        
        [sheet showInView:_chromecastButton];
    } else {
        //Already connected information
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"Casting to %@", nil),
                         rearMenu.selectedDevice.friendlyName];
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

#pragma mark - MCSession Delegate
-(void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
      fromPeer:(MCPeerID *)peerID
         atURL:(NSURL *)localURL
     withError:(NSError *)error
{
    
    NSLog(@"Session::didFinishReceivingResourceWithName");
}

-(void)session:(MCSession *)session
didReceiveData:(NSData *)data
      fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Session::didReceiveData");
    
}

-(void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
      withName:(NSString *)streamName
      fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Session::didReceiveStream");
}

-(void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
      fromPeer:(MCPeerID *)peerID
  withProgress:(NSProgress *)progress
{
    NSLog(@"Session::didStartReceivingResourceWithName");
}

-(void)session:(MCSession *)session
          peer:(MCPeerID *)peerID
didChangeState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected:
            NSLog(@"Session::didChangeState: MCSessionStateConnected");
            break;
            
        case MCSessionStateConnecting:
            NSLog(@"Session::didChangeState: MCSessionStateConnecting");
            break;
            
        case MCSessionStateNotConnected:
            NSLog(@"Session::didChangeState: MCSessionStateNotConnect");
            break;
            
        default:
            break;
    }
}
@end
