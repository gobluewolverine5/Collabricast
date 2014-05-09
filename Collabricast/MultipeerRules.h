//
//  MultipeerRules.h
//  MediaCast
//
//  Created by Evan Hsu on 4/1/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#ifndef MediaCast_MultipeerRules_h
#define MediaCast_MultipeerRules_h

// Include any system framework and library headers here that should be included in all compilation units.
// You will also need to set the Prefix Header build setting of one or more of your targets to reference this file.

#define BROADCAST_SLIDESHOW 0   //Host starts playing slideshow
#define BROADCAST_PICTURE   1
#define STOP_SLIDESHOW      2
#define PEER_PICTURE        4
#define PEER_UPVOTE         5
#define PEER_DOWNVOTE       6

#define NO_VOTE     0
#define UP_VOTE     1
#define DOWN_VOTE   2
#endif
