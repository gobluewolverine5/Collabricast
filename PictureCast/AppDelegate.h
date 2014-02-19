//
//  AppDelegate.h
//  PictureCast
//
//  Created by Evan Hsu on 2/9/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PictureCast;
@class HTTPServer;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    HTTPServer *httpServer;
    
    UIWindow *window;
    PictureCast *viewController;
    UInt16 port_number;
}

@property (strong, nonatomic) IBOutlet UIWindow *window;
@property (nonatomic) IBOutlet PictureCast *viewController;
@property (nonatomic) UInt16 port_number;

- (void) setHostPath:(NSString *)path;
- (NSString *) cacheURL;

@end
