//
//  PhotoPickerViewController.m
//  GCAPIv2TestApp
//
//  Created by Chute Corporation on 7/24/13.
//  Copyright (c) 2013 Aleksandar Trpeski. All rights reserved.
//

#import "GCPhotoPickerViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "GCPhotoPickerCell.h"
#import "GCAssetsCollectionViewController.h"
#import "GCAccountMediaViewController.h"
#import "GCAlbumViewController.h"
#import "NSDictionary+ALAsset.h"
#import "GCServiceAccount.h"
#import "GCAccount.h"
#import "GCPhotoPickerConfiguration.h"
#import "GCMacros.h"

#import "GetChute.h"
#import "MBProgressHUD.h"

@interface GCPhotoPickerViewController ()

@property (nonatomic) BOOL isItDevice;

@property (assign, nonatomic) BOOL hasLocal;
@property (strong, nonatomic) NSArray *localFeatures;
@property (assign, nonatomic) BOOL hasOnline;
@property (strong, nonatomic) NSArray *services;
@property (nonatomic, strong) UIBarButtonItem *logoutButton;

@end

@implementation GCPhotoPickerViewController

@synthesize delegate, isMultipleSelectionEnabled = _isMultipleSelectionEnabled;
@synthesize isItDevice;
@synthesize navigationTitle = _navigationTitle;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = self.navigationTitle? self.navigationTitle: @"Photo Picker";
    
    [self setNavBarItems];

    GCClient *apiClient = [GCClient sharedClient];

    if([apiClient isLoggedIn] == NO)
        [self setLogoutNavBarButton:NO];
    else
        [self setLogoutNavBarButton:YES];
    
    [self.tableView registerClass:[GCPhotoPickerCell class] forCellReuseIdentifier:@"GroupCell"];

    [self setLocalFeatures:[[GCPhotoPickerConfiguration configuration] localFeatures]];
    [self setServices:[[GCPhotoPickerConfiguration configuration] services]];
    
    if([self.localFeatures count] > 0)
        self.hasLocal = YES;
    else
        self.hasLocal = NO;
    
    if( [self.services count] > 0)
        self.hasOnline = YES;
    else
        self.hasOnline = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return (self.hasLocal + self.hasOnline);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0 && self.hasLocal)
        return GCLocalizedString(@"picker.local_services");
    return GCLocalizedString(@"picker.local_services");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 && self.hasLocal)
        return [self.localFeatures count];
    return [self.services count];
}

- (GCPhotoPickerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GroupCell";

    GCPhotoPickerCell *cell = [[GCPhotoPickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
   
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if(indexPath.section == 0 && self.hasLocal){
        
        NSString *serviceName = [self.localFeatures objectAtIndex:indexPath.row];
        NSString *cellTitle = [[serviceName capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        
        if ([cellTitle isEqualToString:@"Camera Photos"]) {
            cellTitle = GCLocalizedString(@"picker.choose_photo");
            [cell.imageView setImage:[UIImage imageNamed:@"defaultThumb.png"]];
        }
        if ([cellTitle isEqualToString:@"Take Photo"]) {
            cellTitle = GCLocalizedString(@"picker.take_photo");
            [cell.imageView setImage:[UIImage imageNamed:@"camera.png"]];
        }
        if ([cellTitle isEqualToString:@"Last Taken Photo"])
        {
            cellTitle = GCLocalizedString(@"picker.last_photo_taken");
            [cell.imageView setImage:[UIImage imageNamed:@"defaultThumb.png"]];
        }

        [cell.titleLabel setText:cellTitle];
    }
    else
    {
        NSString *serviceName = [self.services objectAtIndex:indexPath.row];
        GCLoginType loginType = [[GCPhotoPickerConfiguration configuration] loginTypeForString:serviceName];
        NSString *loginTypeString = [[GCPhotoPickerConfiguration configuration] loginTypeString:loginType];
        
        NSString *imageName = [NSString stringWithFormat:@"%@.png", serviceName];
        UIImage *temp = [UIImage imageNamed:imageName];
        [cell.imageView setImage:temp];
        
        NSString *cellTitle = [[serviceName capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];

        for (GCAccount *account in [[GCPhotoPickerConfiguration configuration] accounts]) {
            if([account.type isEqualToString:loginTypeString]){
                if (account.name) {
                    cellTitle = account.name;
                }
                else if (account.username){
                    cellTitle = account.username;
                }
            }
        }
        [cell.titleLabel setText:cellTitle];
    }
    
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0 && self.hasLocal){
        
        
        NSString *serviceName = [self.localFeatures objectAtIndex:indexPath.row];
        NSString *cellTitle = [[serviceName capitalizedString] stringByReplacingOccurrencesOfString:@"_" withString:@" "];

        if ([cellTitle isEqualToString:@"Take Photo"]) {

            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            [picker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [picker setDelegate:self];
            [self presentViewController:picker animated:YES completion:nil];

        }
        else if ([cellTitle isEqualToString:@"Camera Photos"])
        {
            
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            self.isItDevice = YES;
            
            GCAlbumViewController *daVC = [[GCAlbumViewController alloc] init];
            [daVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
            [daVC setSuccessBlock:[self successBlock]];
            [daVC setCancelBlock:[self cancelBlock]];
            [daVC setIsItDevice:self.isItDevice];
            
            [self.navigationController pushViewController:daVC animated:YES];
            
        }
        else if ([cellTitle isEqualToString:GCLocalizedString(@"picker.last_photo_taken")])
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self getLatestPhoto];

        }
    }
    else
    {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.isItDevice = NO;
        
        NSString *serviceName = [self.services objectAtIndex:indexPath.row];
        GCLoginType loginType = [[GCPhotoPickerConfiguration configuration] loginTypeForString:serviceName];
        NSString *loginTypeString = [[GCPhotoPickerConfiguration configuration] loginTypeString:loginType];
        
        
        for (GCAccount *account in [[GCPhotoPickerConfiguration configuration] accounts]) {
            if(!([account.type isEqualToString:@"google"] || [account.type isEqualToString:@"microsoft_account"]))
            {
                if ([account.type isEqualToString:loginTypeString]) {
                    
                    GCAccountMediaViewController *amVC = [[GCAccountMediaViewController alloc] init];
                    [amVC setIsItDevice:self.isItDevice];
                    [amVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
                    [amVC setAccountID:account.shortcut];
                    [amVC setServiceName:serviceName];
                    [amVC setSuccessBlock:[self successBlock]];
                    [amVC setCancelBlock:[self cancelBlock]];
                    
                    [self.navigationController pushViewController:amVC animated:YES];
                    [self.tableView reloadData];
                    return;
                }
            }
        }
        
        [GCLoginView showLoginType:loginType success:^{
            [GCServiceAccount getProfileInfoWithSuccess:^(GCResponseStatus *responseStatus, NSArray *accounts) {
                GCAccount *account;
                for (GCAccount *acc in accounts) {
                    if ([loginTypeString isEqualToString:acc.type])
                        account = acc;
                    
                    [[GCPhotoPickerConfiguration configuration] addAccount:acc];
                }
                if (!account)
                    return;
                
                GCAccountMediaViewController *amVC = [[GCAccountMediaViewController alloc] init];
                [amVC setIsItDevice:self.isItDevice];
                [amVC setIsMultipleSelectionEnabled:self.isMultipleSelectionEnabled];
                [amVC setAccountID:account.shortcut];
                [amVC setServiceName:serviceName];
                [amVC setSuccessBlock:[self successBlock]];
                [amVC setCancelBlock:[self cancelBlock]];
                
                [self setLogoutNavBarButton:YES];
                [self.tableView reloadData];
                [self.navigationController pushViewController:amVC animated:YES];
            } failure:^(NSError *error) {
                GCLogError([error localizedDescription]);
                [[[UIAlertView alloc] initWithTitle:@"Error" message:@"Oops! Something went wrong. Please try again later." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }];
        } failure:^(NSError *error) {
            GCLogError([error localizedDescription]);
        }];
    }
}

#pragma mark - Custom Methods

- (void)getLatestPhoto
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    
    // Enumerate all the photos and videos group by using ALAssetsGroupAll.
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        
        // Within the group enumeration block, filter to enumerate just photos.
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
    
        if (group != nil && [group numberOfAssets] == 0) {
            [[[UIAlertView alloc] initWithTitle:@"Error" message:@"You don't have any photos." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            return;
        }
        
        // Chooses the photo at the last index
        [group enumerateAssetsAtIndexes:[NSIndexSet indexSetWithIndex:([group numberOfAssets] - 1)] options:0 usingBlock:^(ALAsset *alAsset, NSUInteger index, BOOL *innerStop) {
            
            // The end of the enumeration is signaled by asset == nil.
            if (alAsset)
                [self successBlock]([NSDictionary infoFromALAsset:alAsset]);
        }];
    } failureBlock: ^(NSError *error) {
        // Typically you should handle an error more gracefully than this.
        NSLog(@"No groups to be enumerated.");
    }];

}

- (void)setNavBarItems
{
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    self.logoutButton = [[UIBarButtonItem alloc] initWithTitle:GCLocalizedString(@"picker.logout") style:UIBarButtonItemStyleBordered target:self action:@selector(logout)];
    
    [self.navigationItem setLeftBarButtonItem:cancelButton];
}

- (void)setLogoutNavBarButton:(BOOL)toBeAdded
{
    if(toBeAdded == YES)
        [self.navigationItem setRightBarButtonItem:self.logoutButton];
    else
        [self.navigationItem setRightBarButtonItem:nil];
}

- (void)logout
{
    GCClient *apiClient = [GCClient sharedClient];
    [apiClient clearCookiesForChute];
    [apiClient clearAuthorizationHeader];
    [[GCPhotoPickerConfiguration configuration] removeAllAccounts];
    
    [self setLogoutNavBarButton:NO];
    [self.tableView reloadData];
}


- (void)cancel
{
    if([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)])
    {
        [self.delegate imagePickerControllerDidCancel:(PhotoPickerViewController *)self.navigationController];
    }
}

#pragma mark - UIImagePicker Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self cancelBlock]();
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self successBlock](info);
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingArrayOfMediaWithInfo:(NSArray *)info
{
    [self successBlock](info);
}

#pragma mark - Callbacks

- (void (^)(id selectedItems))successBlock
{
    void (^successBlock)(id selectedItems) = ^(id selectedItems){
        if ([selectedItems isKindOfClass:[NSDictionary class]] && [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingMediaWithInfo:)]) {
            [self.delegate imagePickerController:(PhotoPickerViewController *)self.navigationController didFinishPickingMediaWithInfo:selectedItems];
        }
        else if ([selectedItems isKindOfClass:[NSArray class]] && [self.delegate respondsToSelector:@selector(imagePickerController:didFinishPickingArrayOfMediaWithInfo:)]) {
            [self.delegate imagePickerController:(PhotoPickerViewController *)self.navigationController didFinishPickingArrayOfMediaWithInfo:selectedItems];
        }
    };
    return successBlock;
}

- (void (^)(void))cancelBlock
{
    void (^cancelBlock)(void) = ^{
        if([self.delegate respondsToSelector:@selector(imagePickerControllerDidCancel:)])
        {
            [self.delegate imagePickerControllerDidCancel:(PhotoPickerViewController *)self.navigationController];
        }
    };
    return cancelBlock;
}

#pragma mark - Setters

- (void)setIsMultipleSelectionEnabled:(BOOL)isMultipleSelectionEnabled
{
    if(_isMultipleSelectionEnabled != isMultipleSelectionEnabled)
        _isMultipleSelectionEnabled = isMultipleSelectionEnabled;
}


@end
