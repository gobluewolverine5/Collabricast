//
//  User.h
//  MediaCast
//
//  Created by Evan Hsu on 3/23/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>

@interface User : NSObject

@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) MCPeerID *peerID;

- (id) initWithPeerID:(MCPeerID *)peerID identifier:(NSString *)identifier;
- (NSString *) name;
- (BOOL)isEqualToUser:(User *)object;

@end
