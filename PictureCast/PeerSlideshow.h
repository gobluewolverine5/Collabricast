//
//  PeerSlideshow.h
//  MediaCast
//
//  Created by Evan Hsu on 3/23/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "ELCImagePickerController.h"
#import "ELCAlbumPickerController.h"

@interface PeerSlideshow : UIViewController <
    MCSessionDelegate,
    ELCImagePickerControllerDelegate,
    UITableViewDataSource,
    UITableViewDelegate,
    MCNearbyServiceBrowserDelegate,
    MCBrowserViewControllerDelegate
>

@property (strong, nonatomic) IBOutlet UILabel *peerDeviceLabel;
@property (strong, nonatomic) IBOutlet UITableView *imageTable;
@property (strong, nonatomic) IBOutlet UIImageView *statusImg;


@property (nonatomic, retain) MCNearbyServiceBrowser *browser;
@property (nonatomic, retain) MCPeerID *localPeerID;
@property (nonatomic, retain) MCPeerID *remotePeerID;
@property (nonatomic, retain) MCSession *session;

- (IBAction)selectImage:(id)sender;
- (IBAction)endSession:(id)sender;

@end
