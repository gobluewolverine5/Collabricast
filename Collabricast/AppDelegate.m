//
//  AppDelegate.m
//  PictureCast
//
//  Created by Evan Hsu on 2/9/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "AppDelegate.h"
#import "PictureCast.h"
#import "HTTPServer.h"
#import "DDLog.h"
#import "DDTTYLogger.h"


//Log levels: off, error, warn, info, verbose
static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@implementation AppDelegate

@synthesize window;
@synthesize viewController;
@synthesize port_number;

- (void) startServer
{
    NSError *error;
    if ([httpServer start:&error]) {
        port_number = [httpServer listeningPort];
        NSLog(@"Domain %@", [httpServer domain]);
        NSLog(@"interface %@", [httpServer interface]);
        DDLogInfo(@"Started HTTP Server on port %hu", port_number);
    } else {
        DDLogError(@"Error starting HTTP Server: %@", error);
    }
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //self.window.backgroundColor = [UIColor whiteColor];
    //[self.window makeKeyAndVisible];
    
    // Configure our logging framework.
	// To keep things simple and fast, we're just going to log to the Xcode console.
	[DDLog addLogger:[DDTTYLogger sharedInstance]];
	
	// Create server using our custom MyHTTPServer class
	httpServer = [[HTTPServer alloc] init];
	
	// Tell the server to broadcast its presence via Bonjour.
	// This allows browsers such as Safari to automatically discover our service.
	[httpServer setType:@"_http._tcp."];
	
	// Normally there's no need to run our server on any specific port.
	// Technologies like Bonjour allow clients to dynamically discover the server's port at runtime.
	// However, for easy testing you may want force a certain port so you can just hit the refresh button.
	// [httpServer setPort:12345];
	
	// Serve files from our embedded Web folder
    
    //NSString * docsDir = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
	//NSString *webPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"images"];
	DDLogInfo(@"Setting document root: %@", [self cacheURL]);
	
	//[httpServer setDocumentRoot:docsDir];
    [httpServer setDocumentRoot:[self cacheURL]];
    
    [self startServer];
    
    // Add the view controller's view to the window and display.
    //[window addSubview:viewController.view];
    //[window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [httpServer stop];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [self startServer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *saveDirectory = [self cacheURL];
    NSArray *cacheFiles = [fileManager contentsOfDirectoryAtPath:saveDirectory error:nil];
    for (NSString *file in cacheFiles) {
        [fileManager removeItemAtPath:[saveDirectory stringByAppendingPathComponent:file]
                                error:nil];
    }
}

- (void) setHostPath:(NSString *)path
{
    [httpServer setDocumentRoot:path];
}

- (NSString *) cacheURL
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *dirs = [fm URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
    NSURL *cacheURL = dirs[0];
    
    return [cacheURL relativePath];
}
@end
