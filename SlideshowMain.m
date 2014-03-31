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
#import "SettingsTableVC.h"
#import "CBAlertView.h"
#import "RearMenu.h"
#import "SWRevealViewController.h"
#import "SlideshowReorder.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

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
    NSMutableArray *peers;
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

@synthesize advertiser;
@synthesize localPeerID;


#pragma mark - View Controller Init
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
    
    //_menuButton.tintColor = [UIColor colorWithRed:0.0/255.0 green:222.0/255.0 blue:242.0/255.0 alpha:1];
    _menuButton.tintColor = [UIColor whiteColor];
    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);
    
    PhotoPickerViewController *picker = [PhotoPickerViewController new];
    [picker setDelegate:self];
    [picker setIsMultipleSelectionEnabled:YES];
    [self presentViewController:picker animated:YES completion:Nil];
    
    duration = 10;
    imageQuality = 0.7;
    
    picture_ops = [[pictureOps alloc] init];
    [picture_ops clearCache];
    
    images       = [[NSMutableArray alloc]init];
    image_files  = [[NSMutableArray alloc]init];
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
    
    /* BROADCASTING PEER CONNECTION */
    static NSString * const ServiceType = @"media-cast";
    localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    
    advertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:localPeerID
                                                   discoveryInfo:Nil
                                                     serviceType:ServiceType];
    advertiser.delegate = self;
    [advertiser startAdvertisingPeer];
    NSLog(@"localPeerID: %@", localPeerID.displayName);
    _session = [[MCSession alloc] initWithPeer:localPeerID
                              securityIdentity:nil
                          encryptionPreference:MCEncryptionNone];
    _session.delegate = self;
    _peerHostLookup = [[NSMutableDictionary alloc] init];
    peers = [[NSMutableArray alloc] init];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    _session.delegate = self;
    RearMenu *rearMenu = (RearMenu *) self.revealViewController.rearViewController;
    rearMenu.deviceManagerObject.delegate = self;
    rearMenu.mediaControlChannel.delegate = self;
    [rearMenu.deviceScannerObject addListener:self];
    [advertiser startAdvertisingPeer];
    if ([images count] > 0) [self refreshSlideshowQueuePreview];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [advertiser stopAdvertisingPeer];
    RearMenu *rearMenu = (RearMenu *) self.revealViewController.rearViewController;
    [rearMenu.deviceScannerObject removeListener:self];
    
    //if ([picture_ops clearCache]) NSLog(@"Cleared Cache");
    //image_files = Nil;
    //images      = Nil;
}

-(void)dealloc
{
    while ([image_files count] > 0) {
        [image_files removeLastObject];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toPlaySlideshow"]) {
        PlaySlideshow *play_slideshow = (PlaySlideshow *) segue.destinationViewController;
        play_slideshow.images       = images;
        play_slideshow.image_files  = image_files;
        play_slideshow.duration     = duration;
        play_slideshow.deviceScannerObject = deviceScannerObject;
        play_slideshow.deviceManagerObject = deviceManagerObject;
        play_slideshow.mediaControlChannel = mediaControlChannel;
        play_slideshow.selectedDevice = selectedDevice;
        play_slideshow.session_id = session_id;
        
        play_slideshow.session      = _session;
        play_slideshow.peers        = peers;
        play_slideshow.localPeerID  = localPeerID;
    }
    else if ([segue.identifier isEqualToString:@"toSettingsTableVC"]) {
        SettingsTableVC *settings_table = (SettingsTableVC *) segue.destinationViewController;
        settings_table.delegate = self;
        settings_table.imageQuality = imageQuality;
        settings_table.duration = duration;
    }
    else if ([segue.identifier isEqualToString:@"toSlideshowReorder"]) {
        SlideshowReorder *slideshow_reorder = (SlideshowReorder *) segue.destinationViewController;
        slideshow_reorder.images      = images;
        slideshow_reorder.image_files = image_files;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MFMailComposeViewControllerDelegate
-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult: (MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated:NO completion:NULL];
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
        
        PhotoPickerViewController *picker = [PhotoPickerViewController new];
        [picker setDelegate:self];
        [picker setIsMultipleSelectionEnabled:YES];
    
        [self presentViewController:picker animated:YES completion:Nil];
        
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
    [self performSegueWithIdentifier:@"toSettingsTableVC" sender:nil];
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
    [self broadCastSlideshow];
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

- (IBAction)shareSlides:(id)sender {
   
    NSLog(@"shareSlides selected");
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate  = self;
        //[mailViewController setToRecipients :people];
        [mailViewController setMessageBody:@"Created by MediaCast iOS\n------------\n" isHTML:NO];
        [mailViewController setSubject:@"MediaCast Slideshow"];

        for (UIImage *image in image_files) {
            if (image) {
                NSData *image_data = UIImageJPEGRepresentation(image, 1);
                [mailViewController addAttachmentData:image_data  mimeType:@"image/jpeg" fileName:@"attached_image"];
                
            }
        }
        [self presentViewController:mailViewController animated:YES completion:NULL];
    }
    else {
        NSLog(@"Could not open email");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle     :@"Error"
                              message           :@"Could not open email"
                              delegate          :nil
                              cancelButtonTitle :@"OK"
                              otherButtonTitles :nil];
        [alert show];
    }
}

- (IBAction)toSlideshowReorder:(id)sender
{
    [self performSegueWithIdentifier:@"toSlideshowReorder" sender:Nil];
}

- (void) refreshSlideshowQueuePreview
{
    if (currentIndex >= image_files.count) {
        currentIndex = image_files.count - 1;
    }
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

#pragma mark - imagePickerController Delegate
-(void)imagePickerControllerDidCancel:(PhotoPickerViewController *)picker
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info
{
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"info: %@",info);
    for (int i = 0; i < [info count]; i++) {
        NSDictionary *infoDict = [info objectAtIndex:i];
        
        [image_files addObject:[UIImage imageWithData:UIImageJPEGRepresentation([picture_ops
                                                                                 saveOriginalImage:infoDict
                                                                                 highQuality:imageQuality], 0.1)]];
        [images addObject:[picture_ops returnFileURL]];
    }
    [self refreshSlideshowQueuePreview];
}

-(void)imagePickerController:(PhotoPickerViewController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    NSLog(@"info: %@",info);
    if (info) {
        
        [image_files addObject:[UIImage imageWithData:UIImageJPEGRepresentation([picture_ops
                                                                                 saveOriginalImage:info
                                                                                 highQuality:imageQuality], 0.1)]];
        [images addObject:[picture_ops returnFileURL]];
    }
    [self refreshSlideshowQueuePreview];
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
    RearMenu *rearMenu = (RearMenu *) self.revealViewController.rearViewController;
    [rearMenu.deviceManagerObject launchApplication:@"549D1581"];
}

- (void)deviceManager:(GCKDeviceManager *)deviceManager
didConnectToCastApplication:(GCKApplicationMetadata *)applicationMetadata
            sessionID:(NSString *)sessionID
  launchedApplication:(BOOL)launchedApp {
    
    RearMenu *rearMenu = (RearMenu *) self.revealViewController.rearViewController;
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

- (void) broadCastSlideshow
{
    NSDictionary *msgpkt = @{@"type": [NSNumber numberWithInt:0]};
    NSData *data = [NSJSONSerialization dataWithJSONObject:msgpkt options:0 error:Nil];
    [_session sendData:data toPeers:peers withMode:MCSessionSendDataReliable error:Nil];
}

#pragma mark UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    RearMenu *rearMenu = (RearMenu *) self.revealViewController.rearViewController;
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
    RearMenu *rearMenu = (RearMenu *) self.revealViewController.rearViewController;
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
    RearMenu *rearMenu = (RearMenu *) self.revealViewController.rearViewController;
  rearMenu.deviceManagerObject  = nil;
  rearMenu.selectedDevice       = nil;
  NSLog(@"Device disconnected");
}

- (void)updateButtonStates {
    RearMenu *rearMenu = (RearMenu *) self.revealViewController.rearViewController;
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
    RearMenu *rearMenu = (RearMenu *) self.revealViewController.rearViewController;
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
#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void) advertiser:(MCNearbyServiceAdvertiser *)advertiser
    didReceiveInvitationFromPeer:(MCPeerID *)peerID
        withContext:(NSData *)context
  invitationHandler:(void (^)(BOOL, MCSession *))invitationHandler
{
    NSString *msg = [NSString stringWithFormat:@"%@ would like to join your slideshow", peerID.displayName];
    CBAlertView *alert = [[CBAlertView alloc] initWithTitle:@"Invitation Request"
                                                    message:msg
                                          cancelButtonTitle:@"Decline"
                                          otherButtonTitles:@"Accept", nil];
    alert.completion = ^(BOOL canceled, NSInteger buttonIndex) {
        if (canceled) {
            NSLog(@"User Declined Invitation");
            invitationHandler(NO, Nil);
        }
        else {
            NSLog(@"User Accepted Invitation");
            invitationHandler(YES, _session);
        }
    };
    [alert show];
    NSLog(@"peerID.displayName: %@", peerID);
}

#pragma mark - MCSession Delegate
-(void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didNotStartAdvertisingPeer:(NSError *)error
{
    NSLog(@"Error: %@", [error userInfo]);
}

-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Session::didReceiveData");
    NSString *message   = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSURL *url          = [NSURL URLWithString:message];
    _peerHostLookup[peerID.displayName] = [url host];
    dispatch_async(dispatch_get_global_queue(0, 0), ^ {
        NSData * imageData  = [[NSData alloc] initWithContentsOfURL:url];
        if (imageData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [image_files addObject:[UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageWithData:imageData],0.1)]];
                [images addObject:[url absoluteString]];
                [self refreshSlideshowQueuePreview];
            });
        }
    });
    
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Session::didReceiveStream");
}

-(void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
      fromPeer:(MCPeerID *)peerID
         atURL:(NSURL *)localURL
     withError:(NSError *)error
{
    NSLog(@"Session::didFinishReceivingResourceWith Name");
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Session::didStartReceivingResourceWithName");
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateNotConnected: {
            
            dispatch_queue_t backgroundQueue = dispatch_queue_create("slideshowmain.queue", 0);
            
            dispatch_async(backgroundQueue, ^{
                NSLog(@"Session::didChangeState: MCSessionStateNotConnect");
                
                /* REMOVING ALL IMAGES BELONGING TO PEERID */
                NSString *hostString = _peerHostLookup[peerID.displayName];
                for (int i = images.count-1; i >= 0; i--) {
                    NSURL *tempUrl = [NSURL URLWithString:[images objectAtIndex:i]];
                    if ([[tempUrl host] isEqualToString:hostString]) {
                        [images removeObjectAtIndex:i];
                        [image_files removeObjectAtIndex:i];
                    }
                }
                
                /* REMOVING PEER FROM PEER ARRAY */
                for (int i = 0; i < peers.count; i++) {
                    [peers removeObjectAtIndex:i];
                    break;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self refreshSlideshowQueuePreview];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Peer"
                                                                    message:[NSString stringWithFormat:@"%@ has left the session",peerID.displayName]
                                                                   delegate:self
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles: nil];
                    [alert show];
                });
            });
            break;
        }
        case MCSessionStateConnecting:
            NSLog(@"Session::didChangeState: MCSessionStateConnecting");
            break;
        case MCSessionStateConnected:
            NSLog(@"Session::didChangeState: MCSessionStateConnected");
            /* ADDING TO PEER ARRAY */
            [peers addObject:peerID];
            break;
            
        default:
            NSLog(@"Session::didChangeState: default");
            break;
    }
}
@end
