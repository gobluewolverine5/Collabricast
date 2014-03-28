//
//  PeerSlideshow.m
//  MediaCast
//
//  Created by Evan Hsu on 3/23/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "PeerSlideshow.h"
#import "pictureOps.h"
#import "AppDelegate.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

@interface PeerSlideshow ()

@end

@implementation PeerSlideshow {
    NSMutableArray *images;
    NSMutableArray *image_files;
    pictureOps *pic_ops;
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
    
    [_peerDeviceLabel setText:@"NOT CONNECTED"];
    [_statusImg setImage:[UIImage imageNamed:@"OffIcon.png"]];
    
    image_files = [[NSMutableArray alloc] init];
    images      = [[NSMutableArray alloc] init];
    pic_ops     = [[pictureOps alloc] init];
    
    _imageTable.delegate    = self;
    _imageTable.dataSource  = self;
    
    _localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    _session     = [[MCSession alloc] initWithPeer:_localPeerID];
    _session.delegate = self;
    
    static NSString * const XXServiceType = @"media-cast";
    
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_localPeerID
                                                serviceType:XXServiceType];
    MCBrowserViewController *mcb = [[MCBrowserViewController alloc] initWithBrowser:_browser
                                                                            session:_session];
    mcb.delegate = self;
    [self presentViewController:mcb
                       animated:YES
                     completion:^{
                         [_browser startBrowsingForPeers];
                     }];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [pic_ops clearCache];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - IBAction
- (IBAction)selectImage:(id)sender {
    ELCImagePickerController *imagePicker = [[ELCImagePickerController alloc] initImagePicker];
    imagePicker.maximumImagesCount      = 5;
    imagePicker.returnsOriginalImage    = NO;
    imagePicker.imagePickerDelegate     = self;
    [self presentViewController:imagePicker animated:YES completion:Nil];
}

- (IBAction)endSession:(id)sender {
    [_session disconnect];
    [_peerDeviceLabel setText:@"NOT CONNECTED"];
    [_statusImg setImage:[UIImage imageNamed:@"OffIcon.png"]];
    
}

#pragma mark - MCNearbyBrowser Delegate
-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    [self dismissViewControllerAnimated:YES completion:Nil];
}


#pragma mark - ELCImage Picker Delegate
- (void)elcImagePickerController:(ELCImagePickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
    if (info.count > 0) {
        for (int i = 0; i < [info count]; i++) {
            NSDictionary *infoDict = [info objectAtIndex:i];
            
            [image_files addObject:[UIImage imageWithData:UIImageJPEGRepresentation([pic_ops
                                                                                     saveImage:infoDict
                                                                                     highQuality:0.7], 0.1)]];
            [images addObject:[pic_ops returnFileName]];
            NSString *message   = [pic_ops returnFileURL];
            NSData *data        = [message dataUsingEncoding:NSUTF8StringEncoding];
            NSError *error      = nil;
            if (![self.session sendData:data
                toPeers:@[_remotePeerID]
                withMode:MCSessionSendDataReliable error:&error]) {
                NSLog(@"error: %@", error);
            }
        }
        [_imageTable reloadData];
    }
}

-(void)elcImagePickerControllerDidCancel:(ELCImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [image_files count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell           = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]
                initWithStyle   :UITableViewCellStyleDefault
                reuseIdentifier :CellIdentifier];
    }
    
    // Configure the cell...
    cell.imageView.image = [image_files objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor colorWithRed:171.0/255.0
                                           green:205.0/255.0
                                            blue:207.0/255.0
                                           alpha:1];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIImage *image = [image_files objectAtIndex:indexPath.row];
    CGFloat ratio = image.size.width/155;
    return image.size.height/ratio;
}

#pragma mark - MCSession Delegate
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Session::didReceiveData");
}

-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Session::didReceiveStream");
}

-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{
    NSLog(@"Session::didFinishReceivingResourceWithName");
}

-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{
    NSLog(@"Session::didStartReceivingResourceWithName");
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateNotConnected: {
            dispatch_queue_t backgroundQueue = dispatch_queue_create("peerslideshow.queue", 0);
            
            dispatch_async(backgroundQueue, ^{
                NSLog(@"Session::didChangeState: MCSessionStateNotConnect");
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Session Ended"
                                                                    message:[NSString stringWithFormat:@"%@ has disconnected", peerID.displayName]
                                                                   delegate:self
                                                          cancelButtonTitle:@"Ok"
                                                          otherButtonTitles:nil];
                    [alert show];
                });
            });
            break;
        }
        case MCSessionStateConnecting:
            NSLog(@"Session::didChangeState: MCSessionStateConnecting");
            
            break;
        case MCSessionStateConnected: {
            dispatch_queue_t backgroundQueue = dispatch_queue_create("peerslideshow.queue", 0);
            
            dispatch_async(backgroundQueue, ^{
                NSLog(@"Session::didChangeState: MCSessionStateConnected");
                _remotePeerID = peerID;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_peerDeviceLabel setText:peerID.displayName];
                    [_statusImg setImage:[UIImage imageNamed:@"OnIcon.png"]];
                });
            });
            break;
        }
        default:
            NSLog(@"Session::didChangeState: default");
            break;
    }
}

#pragma mark -IPAddress
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
