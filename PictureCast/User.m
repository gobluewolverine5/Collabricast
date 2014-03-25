//
//  User.m
//  MediaCast
//
//  Created by Evan Hsu on 3/23/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "User.h"

@implementation User

- (id) initWithPeerID:(MCPeerID *)peerID identifier:(NSString *)identifier
{
    if (self ==  [super init]) {
        _peerID     = peerID;
        _identifier = identifier;
    }
    return self;
}

- (NSString *)name
{
    return _peerID.displayName;
}

- (BOOL)isEqualToUser:(User *)object
{
	BOOL status = (object && [_identifier isEqual:object.identifier]);
    
	return status;
}
@end
