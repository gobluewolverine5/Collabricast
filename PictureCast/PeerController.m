//
//  PeerController.m
//  MediaCast
//
//  Created by Evan Hsu on 3/28/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "PeerController.h"

@interface PeerController ()

@end

@implementation PeerController {
    MCSession *session;
    MCPeerID *local_peerID;
    MCPeerID *remote_peerID;
    NSNumber *index;
    NSString *url;
}

@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initWithSession:(MCSession *)ses localPeer:(MCPeerID *)lPeer remotePeer:(MCPeerID *)rPeer
{
    session         = ses;
    local_peerID    = lPeer;
    remote_peerID   = rPeer;
    
    session.delegate = self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillDisappear:(BOOL)animated
{
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

- (IBAction)upVote:(id)sender
{
}

- (IBAction)downVote:(id)sender
{
}

- (IBAction)keepPhoto:(id)sender
{
}

#pragma mark - MCSession Delegate
-(void)session:(MCSession *)session
didFinishReceivingResourceWithName:(NSString *)resourceName
      fromPeer:(MCPeerID *)peerID
         atURL:(NSURL *)localURL
     withError:(NSError *)error
{
    
    NSLog(@"Session::didFinishReceivingResourceWithName");
}

-(void)session:(MCSession *)session
didReceiveData:(NSData *)data
      fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Session::didReceiveData");
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:Nil];
    NSLog(@"Received json: %@", json);
    if ([json[@"type"] isEqualToNumber:[NSNumber numberWithInt:1]]) {
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("peercontroller.queue", 0);
        dispatch_async(backgroundQueue, ^{
            url     = json[@"url"];
            index   = json[@"index"];
            NSURL *address = [NSURL URLWithString:url];
            NSData * imageData  = [[NSData alloc] initWithContentsOfURL:address];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                _imagePreview.image = [UIImage imageWithData:UIImageJPEGRepresentation([UIImage imageWithData:imageData], 0.1)];
                
            });
        });
    }
    else if ([json[@"type"] isEqualToNumber:[NSNumber numberWithInt:2]]) {
        
        dispatch_queue_t backgroundQueue = dispatch_queue_create("peercontroller.queue", 0);
        dispatch_async(backgroundQueue, ^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate peerControllerDidDismiss];
                
            });
        });
    }
    
}

-(void)session:(MCSession *)session
didReceiveStream:(NSInputStream *)stream
      withName:(NSString *)streamName
      fromPeer:(MCPeerID *)peerID
{
    NSLog(@"Session::didReceiveStream");
}

-(void)session:(MCSession *)session
didStartReceivingResourceWithName:(NSString *)resourceName
      fromPeer:(MCPeerID *)peerID
  withProgress:(NSProgress *)progress
{
    NSLog(@"Session::didStartReceivingResourceWithName");
}

-(void)session:(MCSession *)session
          peer:(MCPeerID *)peerID
didChangeState:(MCSessionState)state
{
    switch (state) {
        case MCSessionStateConnected:
            NSLog(@"Session::didChangeState: MCSessionStateConnected");
            break;
            
        case MCSessionStateConnecting:
            NSLog(@"Session::didChangeState: MCSessionStateConnecting");
            break;
            
        case MCSessionStateNotConnected:
            NSLog(@"Session::didChangeState: MCSessionStateNotConnect");
            break;
            
        default:
            break;
    }
}
@end