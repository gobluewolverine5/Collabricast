//
//  Home.m
//  MediaCast
//
//  Created by Evan Hsu on 3/24/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "Home.h"
#import "SWRevealViewController.h"
#import "RearMenu.h"

@interface Home ()

@end

@implementation Home {
    UIImage *_cast_btn;
    UIImage *_connected_cast_btn;
    RearMenu *rearMenu;
}

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
    //_menuButton.tintColor = [UIColor colorWithRed:199.0/255.0 green:244.0/255.0 blue:100.0/255.0 alpha:1];
    _menuButton.tintColor = [UIColor whiteColor];
    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);
    
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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"Main Menu Appeared");
    rearMenu.deviceManagerObject.delegate = self;
    [rearMenu.deviceScannerObject addListener:self];
    if (!(rearMenu.deviceManagerObject && rearMenu.deviceManagerObject.isConnected)) {
        rearMenu.selectedDevice = nil;
    }
    [self updateButtonStates];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
