//
//  PeerController.h
//  MediaCast
//
//  Created by Evan Hsu on 3/28/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@protocol PeerControllerDelegate;

@interface PeerController : UIViewController <
    MCSessionDelegate
>

@property (weak) id <PeerControllerDelegate> delegate;

@property (strong, nonatomic) IBOutlet UIImageView *imagePreview;

- (IBAction)upVote:(id)sender;
- (IBAction)downVote:(id)sender;
- (IBAction)keepPhoto:(id)sender;

- (void)initWithSession:(MCSession*)ses
              localPeer:(MCPeerID*)lPeer
             remotePeer:(MCPeerID*)rPeer;

@end

@protocol PeerControllerDelegate <NSObject>

@required

- (void)peerControllerDidDismiss;

@end