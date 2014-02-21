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
    CGFloat firstX;
    CGFloat firstY;
    CGFloat imageTopBound;
    CGFloat imageBottomBound;
    CGFloat imageLeftBound;
    CGFloat imageRightBound;
    CGFloat minHeight;
    CGFloat minWidth;
    BOOL drawing;
}

@synthesize deviceScannerObject;
@synthesize deviceManagerObject;
@synthesize containerView;
@synthesize imagePreview;
@synthesize imageDrawingProgress;
@synthesize imageDrawing;
@synthesize selectedDevice;
@synthesize mediaControlChannel;
@synthesize session_id;
@synthesize drawModeButton;


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

    //Drawing
    red     = 0.0 / 255.0;
    green   = 0.0 / 255.0;
    blue    = 0.0 / 255.0;
    brush   = 3.0;
    opacity = 1.0;
    Mode    = 0;
    drawing = FALSE;
    
    [imageDrawing setUserInteractionEnabled:YES];
    UIPinchGestureRecognizer *pinch_gr = [[UIPinchGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handlePinch:)];
    pinch_gr.delegate = self;
    UIPanGestureRecognizer *pan_gr = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(handlePan:)];
    pan_gr.delegate = self;
    [imageDrawing addGestureRecognizer:pinch_gr];
    [imageDrawing addGestureRecognizer:pan_gr];
    
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

- (void) viewDidAppear:(BOOL)animated
{
    firstX = 0;
    firstY = 0;
    imageTopBound    = imagePreview.center.y - imagePreview.bounds.size.height/2;
    imageBottomBound = imagePreview.center.y + imagePreview.bounds.size.height/2;
    imageLeftBound   = imagePreview.center.x - imagePreview.bounds.size.width/2;
    imageRightBound  = imagePreview.center.x + imagePreview.bounds.size.width/2;
    minHeight        = imageBottomBound - imageTopBound;
    minWidth         = imageRightBound - imageLeftBound;
    NSLog(@"minHeight: %f", minHeight);
    NSLog(@"minWidth: %f", minWidth);
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction
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

- (IBAction)drawMode:(id)sender
{
    if (drawing) {
        [imageDrawing setUserInteractionEnabled:YES];
        [drawModeButton setTintColor:[UIColor lightGrayColor]];
        drawing = FALSE;
    }
    else {
        [imageDrawing setUserInteractionEnabled:NO];
        [self resetImagePosition];
        UIColor *lightblue = [UIColor colorWithRed:0 green:222 blue:242 alpha:1];
        [drawModeButton setTintColor:lightblue];
        drawing = TRUE;
    }
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
                                                                                streamType:GCKMediaStreamTypeUnknown
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

#pragma mark - Image Gestures
- (void)handlePinch:(UIPinchGestureRecognizer *)gestureRecognizer
{
    static CGRect initialBounds;
    
    UIView *view = gestureRecognizer.view;
    CGFloat factor =[(UIPinchGestureRecognizer *)gestureRecognizer scale];
    NSLog(@"factor: %f", factor);
    
    if(gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        initialBounds = view.bounds;
    }
   
    [UIView beginAnimations:@"animate" context:nil];
    [UIView setAnimationDuration:0.2];
    CGAffineTransform transform = CGAffineTransformScale(CGAffineTransformIdentity, factor, factor);
    CGRect rect = CGRectApplyAffineTransform(initialBounds, transform);
    if (rect.size.width >= minWidth && rect.size.height >= minHeight) {
        view.bounds = rect;
        imagePreview.bounds = rect;
        imageDrawingProgress.bounds = rect;
        //containerView.bounds = rect;
        
        if (imagePreview.center.x + imagePreview.bounds.size.width/2 < imageRightBound) {
            CGFloat change = imageRightBound - (imagePreview.center.x + imagePreview.bounds.size.width/2);
            view.center = CGPointMake(view.center.x + change, view.center.y);
            imagePreview.center = CGPointMake(view.center.x + change, view.center.y);
            imageDrawingProgress.center = CGPointMake(view.center.x + change, view.center.y);
            //containerView.center = CGPointMake(view.center.x + change, view.center.y);
        }
        if (imagePreview.center.x - imagePreview.bounds.size.width/2 > imageLeftBound) {
            CGFloat change = (imagePreview.center.x - imagePreview.bounds.size.width/2) - imageLeftBound;
            view.center = CGPointMake(view.center.x - change, view.center.y);
            imagePreview.center = CGPointMake(view.center.x - change, view.center.y);
            imageDrawingProgress.center = CGPointMake(view.center.x - change, view.center.y);
            //containerView.center = CGPointMake(view.center.x - change, view.center.y);
        }
        if (imagePreview.center.y - imagePreview.bounds.size.height/2 > imageTopBound) {
            CGFloat change = (imagePreview.center.y - imagePreview.bounds.size.height/2) - imageTopBound;
            view.center = CGPointMake(view.center.x, view.center.y - change);
            imagePreview.center = CGPointMake(view.center.x, view.center.y - change);
            imageDrawingProgress.center = CGPointMake(view.center.x, view.center.y - change);
            //containerView.center = CGPointMake(view.center.x, view.center.y - change);
        }
        if (imagePreview.center.y + imagePreview.bounds.size.height/2 < imageBottomBound) {
            CGFloat change = imageBottomBound - (imagePreview.center.y + imagePreview.bounds.size.height/2);
            view.center = CGPointMake(view.center.x, view.center.y + change);
            imagePreview.center = CGPointMake(view.center.x, view.center.y + change);
            imageDrawingProgress.center = CGPointMake(view.center.x, view.center.y + change);
            //containerView.center = CGPointMake(view.center.x, view.center.y + change);
        }
    } else {
        rect.size.width = minWidth;
        rect.size.height= minHeight;
        
        view.bounds = rect;
        view.center = CGPointMake((imageLeftBound + imageRightBound) / 2, (imageTopBound + imageBottomBound)/2);
        
        imagePreview.bounds = rect;
        imagePreview.center = CGPointMake((imageLeftBound + imageRightBound) / 2, (imageTopBound + imageBottomBound)/2);
        
        imageDrawingProgress.bounds = rect;
        imageDrawingProgress.center = CGPointMake((imageLeftBound + imageRightBound) / 2, (imageTopBound + imageBottomBound)/2);
    }
    [UIView commitAnimations];
}

- (void)handlePan:(UIPanGestureRecognizer *)gestureRecognizer
{
    
    CGPoint translation = [gestureRecognizer translationInView:[imageDrawing superview]];
    
    if ([(UIPanGestureRecognizer *)gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        firstX = [[gestureRecognizer view] center].x;
        firstY = [[gestureRecognizer view] center].y;
    }
    
    CGPoint newLocation = CGPointMake(firstX + translation.x, firstY + translation.y);
    //NSLog(@"origin: (%f, %f)", imagePreview.bounds.origin.x, imagePreview.);
    NSLog(@"right bound: %f", imageDrawing.center.x + imageDrawing.bounds.size.width/2);
    CGPoint oldCenter = imageDrawing.center;
    [imageDrawing setCenter:newLocation];
    [imageDrawingProgress setCenter:newLocation];
    [imagePreview setCenter:newLocation];
    //[containerView setCenter:newLocation];
    if (imageDrawing.center.x + imageDrawing.bounds.size.width/2 < imageRightBound ||
        imageDrawing.center.x - imageDrawing.bounds.size.width/2 > imageLeftBound ||
        imageDrawing.center.y - imageDrawing.bounds.size.height/2 > imageTopBound ||
        imageDrawing.center.y + imageDrawing.bounds.size.height/2 < imageBottomBound) {
        
        [UIView beginAnimations:@"animate" context:nil];
        [UIView setAnimationDuration:0.2];
        [imageDrawing setCenter:oldCenter];
        [imageDrawingProgress setCenter:oldCenter];
        [imagePreview setCenter:oldCenter];
        //[containerView setCenter:oldCenter];
        [UIView commitAnimations];
    }
    
}

- (void) resetImagePosition
{
    CGRect rect;
    rect.origin.x = 0;
    rect.origin.y = 0;
    rect.size.width = minWidth;
    rect.size.height= minHeight;
    
    imageDrawing.bounds = rect;
    imageDrawing.center = CGPointMake((imageLeftBound + imageRightBound) / 2, (imageTopBound + imageBottomBound)/2);
    
    imagePreview.bounds = rect;
    imagePreview.center = CGPointMake((imageLeftBound + imageRightBound) / 2, (imageTopBound + imageBottomBound)/2);
    
    imageDrawingProgress.bounds = rect;
    imageDrawingProgress.center = CGPointMake((imageLeftBound + imageRightBound) / 2, (imageTopBound + imageBottomBound)/2);
    
}
#pragma mark - Image Picker delegate
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"info: %@", info);
    [self dismissViewControllerAnimated:YES completion:NULL];
    if ([picture_ops clearCache]) {
        NSLog(@"Cached Succesfully cleared");
    } else {
        NSLog(@"Error clearing cached");
    }
    imagePreview.image = [picture_ops saveImage:info];
    
    [self castCurrentImage:[picture_ops returnFileName]];
}


/*########### ANNOTATION #########*/
#pragma mark - Annotation
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if (drawing) {
        mouseSwiped = NO;
        UITouch *touch = [touches anyObject];
        lastPoint = [touch locationInView:imageDrawingProgress];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

    if (drawing) {
        mouseSwiped = YES;
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:imageDrawingProgress];
        
        UIGraphicsBeginImageContext(imageDrawingProgress.frame.size);
        CGFloat topLeftX = imageDrawing.center.x - imageDrawingProgress.frame.size.width/2;
        CGFloat topLeftY = imageDrawing.center.y - imageDrawingProgress.frame.size.height/2;
        NSLog(@"topLeftX; %f", topLeftX);
        NSLog(@"topLeftY: %f", topLeftY);
        CGFloat scale = imageDrawing.frame.size.height / containerView.frame.size.height;
        //CGFloat widthProportion = (containerView.frame.size.width/imageDrawing.frame.size.width);
        //CGFloat heightProportion = (containerView.frame.size.height/imageDrawing.frame.size.height);
        [self.imageDrawing.image drawInRect:CGRectMake(0, 0, imageDrawingProgress.frame.size.width, imageDrawingProgress.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush * scale);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
        
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        self.imageDrawing.image = UIGraphicsGetImageFromCurrentImageContext();
        [self.imageDrawing setAlpha:opacity];
        UIGraphicsEndImageContext();
        
        lastPoint = currentPoint;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
   
    if (drawing) {
        if(!mouseSwiped) {
            UIGraphicsBeginImageContext(imageDrawingProgress.frame.size);
            CGFloat scale = imageDrawing.frame.size.height / containerView.frame.size.height;
            [self.imageDrawing.image drawInRect:CGRectMake(0, 0, imageDrawingProgress.frame.size.width, imageDrawingProgress.frame.size.height)];
            CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
            CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush * scale);
            CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, opacity);
            CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
            CGContextStrokePath(UIGraphicsGetCurrentContext());
            CGContextFlush(UIGraphicsGetCurrentContext());
            self.imageDrawing.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        [self applyChanges];
    
    }
}

-(IBAction)resetDrawingPressed:(id)sender
{
    [self resetDrawing];
}

-(void) resetDrawing
{
    self.imageDrawing.image = nil;
}

-(void) applyChanges
{
    
    UIGraphicsBeginImageContext(self.imageDrawingProgress.frame.size);
    [self.imageDrawingProgress.image drawInRect:CGRectMake(0, 0, imageDrawingProgress.frame.size.width, imageDrawingProgress.frame.size.height)
                                      blendMode:kCGBlendModeNormal alpha:1.0];
    [self.imageDrawing.image drawInRect:CGRectMake(0, 0, imageDrawingProgress.frame.size.width, imageDrawingProgress.frame.size.height)
                              blendMode:kCGBlendModeNormal alpha:opacity];
    self.imageDrawingProgress.image = UIGraphicsGetImageFromCurrentImageContext();
    self.imageDrawing.image = nil;
    UIGraphicsEndImageContext();
}

/*################ CHROME CAST CODE ###################*/

#pragma mark - GCKDeviceScannerListner
- (void)deviceDidComeOnline:(GCKDevice *)device {
    NSLog(@"Device Found: %@", [device friendlyName]);
    [self updateButtonStates];
}

- (void)deviceDidGoOffline:(GCKDevice *)device {
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

#pragma mark - misc
- (void)showError:(NSError *)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                                    message:NSLocalizedString(error.description, nil)
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
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
@end