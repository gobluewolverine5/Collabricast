//
//  joinSlideshow.m
//  MediaCast
//
//  Created by Evan Hsu on 3/23/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import "joinSlideshow.h"
#import "PeerSlideshow.h"
#import "User.h"
#import "SWRevealViewController.h"

@interface joinSlideshow ()

@end

@implementation joinSlideshow {
    MCPeerID *selectedPeerID;
    UIActivityIndicatorView *loading_wheel;
}


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    _menuButton.tintColor = [UIColor colorWithRed:0.0/255.0 green:222.0/255.0 blue:242.0/255.0 alpha:1];
    _menuButton.target = self.revealViewController;
    _menuButton.action = @selector(revealToggle:);
    
    _userArray = [[NSMutableArray alloc] init];
    
    static NSString * const XXServiceType = @"media-cast";
    _localPeerID = [[MCPeerID alloc] initWithDisplayName:[[UIDevice currentDevice] name]];
    _browser = [[MCNearbyServiceBrowser alloc] initWithPeer:_localPeerID
                                                serviceType:XXServiceType];
    _browser.delegate = self;
    [_browser startBrowsingForPeers];
    _session = [[MCSession alloc] initWithPeer:_localPeerID];
    
    loading_wheel = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loading_wheel removeFromSuperview];
   
    /*
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2
                                                      target:self
                                                    selector:@selector(printStatus)
                                                    userInfo:nil
                                                     repeats:YES];
     */
}

- (void)printStatus
{
    NSLog(@"session connections: %@", _session.connectedPeers);
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toPeerSlideshow"]) {
        PeerSlideshow *peer_slideshow = (PeerSlideshow *) segue.destinationViewController;
        peer_slideshow.localPeerID  = _localPeerID;
        peer_slideshow.remotePeerID = selectedPeerID;
        peer_slideshow.session      = _session;
        
    }
}
#pragma mark - MCNearbyServiceBrowserDelegate
-(void)browser:(MCNearbyServiceBrowser *)browser didNotStartBrowsingForPeers:(NSError *)error
{
    NSLog(@"Browser Error: %@", error.userInfo);
}

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"Found Peer: %@", peerID.displayName);
    NSLog(@"Found Peer Info: %@", info);
    User *user = [[User alloc] initWithPeerID:peerID identifier:@"placeholder"];
    [_userArray addObject:user];
    [self.tableView reloadData];
}

-(void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    NSLog(@"Lost Peer: %@", peerID.displayName);
    for (int i=0; i<[_userArray count]; i++) {
        if ([[[_userArray objectAtIndex:i] name] isEqualToString:peerID.displayName]) {
            [_userArray removeObjectAtIndex:i];
            break;
        }
    }
    [self.tableView reloadData];
}


-(BOOL)browserViewController:(MCBrowserViewController *)browserViewController shouldPresentNearbyPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSLog(@"should present nearby peer");
    return TRUE;
}

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController
{
    NSLog(@"Browser Finished");
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
    NSLog(@"Browser Canceled");
    [self dismissViewControllerAnimated:YES completion:nil];
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
        case MCSessionStateNotConnected:
            NSLog(@"Session::didChangeState: MCSessionStateNotConnect");
            break;
        case MCSessionStateConnecting:
            NSLog(@"Session::didChangeState: MCSessionStateConnecting");
            
            break;
        case MCSessionStateConnected:
            NSLog(@"Session::didChangeState: MCSessionStateConnected");
            [loading_wheel stopAnimating];
            [loading_wheel removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            [self performSegueWithIdentifier:@"toPeerSlideshow" sender:Nil];
            break;
            
        default:
            NSLog(@"Session::didChangeState: default");
            break;
    }
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
    return [_userArray count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

    [self.browser invitePeer:selectedPeerID toSession:_session withContext:Nil timeout:20];
    loading_wheel.frame = CGRectMake(0, 0, 50, 50);
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryView = loading_wheel;
    [loading_wheel startAnimating];
    self.view.userInteractionEnabled = NO;
    _session.delegate = self;
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
    User *user = [_userArray objectAtIndex:indexPath.row];
    cell.textLabel.text = user.name;
    
    selectedPeerID = user.peerID;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
