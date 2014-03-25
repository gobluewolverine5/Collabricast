//
//  joinSlideshow.h
//  MediaCast
//
//  Created by Evan Hsu on 3/23/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface joinSlideshow : UITableViewController <
    MCNearbyServiceBrowserDelegate,
    MCBrowserViewControllerDelegate,
    MCSessionDelegate
>

@property (nonatomic, retain) MCNearbyServiceBrowser *browser;
@property (nonatomic, retain) MCPeerID *localPeerID;
@property (nonatomic, retain) NSMutableArray *userArray;
@property (nonatomic, retain) MCSession *session;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@end
