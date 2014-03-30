//
//  GCPhotoPickerConfiguration.m
//  PhotoPickerPlus-SampleApp
//
//  Created by Aleksandar Trpeski on 10/30/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import "GCPhotoPickerConfiguration.h"

#import "GCAccount.h"
#import "NSObject+GCDictionary.h"
#import "DCKeyValueObjectMapping.h"

static GCPhotoPickerConfiguration *sharedData = nil;
static dispatch_queue_t serialQueue;

static NSString * const kGCSection = @"photopicker";
static NSString * const kGCConfigurationURL = @"configuration_url";
static NSString * const kGCServices = @"services";
static NSString * const kGCLocalFeatures = @"local_features";
static NSString * const kGCAccounts = @"accounts";
static NSString * const kGCLoadAssetsFromWeb = @"load_assets_from_web";

@implementation GCPhotoPickerConfiguration

@synthesize section, configurationURL, services, localFeatures, loadAssetsFromWeb, accounts;

#pragma mark - Singleton Design

+(id)allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        serialQueue = dispatch_queue_create("com.getchute.GCPickerConfiguration", NULL);
        if (sharedData == nil) {
            sharedData = [super allocWithZone:zone];
        }
    });
    
    return sharedData;
}

- (id)init
{
    id __block obj;
    
    dispatch_sync(serialQueue, ^{
        
        obj = [super init];
        
        if (obj) {
            
            [self setSection:kGCSection];
            
            if ([(GCPhotoPickerConfiguration *)obj section]) {
                
                [obj populate:[[GCConfigurationFile dictionaryRepresentation] objectForKey:kGCSection]];
                [obj update];
            }
            
        }
    });
    
    self = obj;
    return self;
}

+ (instancetype)configuration {
    static dispatch_once_t onceToken;
    static GCPhotoPickerConfiguration *sharedData = nil;
    
    dispatch_once(&onceToken, ^{
        sharedData = [[GCPhotoPickerConfiguration alloc] init];
    });
    return sharedData;
}

#pragma mark - GCBaseConfigurationProtocol Methods

- (id)serialized
{
    NSMutableDictionary *stockToSave = [[NSMutableDictionary alloc] init];
    
    if ([self configurationURL]) {
        [stockToSave setObject:[self.configurationURL absoluteString] forKey:kGCConfigurationURL];
    }
    if ([self services])
    {
        [stockToSave setObject:services forKey:kGCServices];
    }
    if ([self localFeatures])
    {
        [stockToSave setObject:localFeatures forKey:kGCLocalFeatures];
    }
    
    if ([self accounts]) {
        NSMutableArray *accountDictionaries = [NSMutableArray new];
        for (GCAccount *account in [self accounts]) {
            [accountDictionaries addObject:[account dictionaryValue]];
        }
        [stockToSave setObject:accountDictionaries forKey:kGCAccounts];
    }
    
    return stockToSave;
}

- (void)populate:(NSDictionary *)configuration
{
    if ([configuration objectForKey:kGCConfigurationURL]) {
        self.configurationURL =  [NSURL URLWithString:[configuration objectForKey:kGCConfigurationURL]];
    }
    else {
        self.configurationURL = nil;
    }
    
    if ([configuration objectForKey:kGCServices]){
        
        NSMutableArray *tmpServices = [NSMutableArray array];
        
        [[configuration objectForKey:kGCServices] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

            if([[[GCPhotoPickerConfiguration sGCServices] allKeys] containsObject:obj]) {
                [tmpServices addObject:obj];
            }
        }];
        self.services = [NSArray arrayWithArray:tmpServices];
    }
    if ([configuration objectForKey:kGCLocalFeatures]){
        
        NSMutableArray *tmpLocalFeatures = [NSMutableArray array];
        
        [[configuration objectForKey:kGCLocalFeatures] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if ([[GCPhotoPickerConfiguration sGCLocalFeatures] containsObject:obj]) {
                [tmpLocalFeatures addObject:obj];
            }
        }];
        self.localFeatures = [NSArray arrayWithArray:tmpLocalFeatures];
    }
    if ([configuration objectForKey:kGCAccounts]) {
        
        DCKeyValueObjectMapping *mapping = [DCKeyValueObjectMapping mapperForClass:[GCAccount class]];
        self.accounts = [NSMutableArray arrayWithArray:[mapping parseArray:[configuration objectForKey:kGCAccounts]]];
    }
    
    if ([configuration objectForKey:kGCLoadAssetsFromWeb]) {
        self.loadAssetsFromWeb = [[configuration objectForKey:kGCLoadAssetsFromWeb] boolValue];
    }
    else {
        self.loadAssetsFromWeb = YES;
    }
    
    [GCConfigurationFile write:self];
}

#pragma mark - Static Variables

static NSSet *_sGCLocalFeatures;
+ (NSSet *)sGCLocalFeatures
{
    if (!_sGCLocalFeatures) {
        _sGCLocalFeatures = [NSSet setWithArray:@[@"take_photo", @"last_taken_photo", @"camera_photos"]];
    }
    return _sGCLocalFeatures;
}

static NSDictionary *_sGCServices;
+ (NSDictionary *)sGCServices
{
    if (!_sGCServices) {
        _sGCServices = @{@"facebook":@"facebook",
                         @"google": @"google",
                         @"googledrive": @"google",
                         @"instagram": @"instagram",
                         @"flickr": @"flickr",
                         @"picasa": @"google",
                         @"dropbox": @"dropbox",
                         @"skydrive": @"microsoft_account",
                         @"twitter":@"twitter",
                         @"chute":@"chute",
                         @"foursquare":@"foursquare"
                         };
    }
    return _sGCServices;
}

#pragma mark - GCPhotoPickerConfiguration Methods

- (GCLoginType)loginTypeForString:(NSString *)serviceString
{
    __block NSString *loginType = [[GCPhotoPickerConfiguration sGCServices] objectForKey:serviceString];
    
    for (int i = 0; i <kGCLoginTypeCount; i++) {
        if ([loginType isEqualToString:kGCLoginTypes[i]]){
            return i;
        }
    }
    return -1;
}

- (NSString *)loginTypeString:(GCLoginType)loginType
{
    if(loginType >= kGCLoginTypeCount)
        return @"";
    return kGCLoginTypes[loginType];
}

- (void)addAccount:(GCAccount *)account
{
    if (![self accounts])
        self.accounts = [NSMutableArray new];
    
    for (int i = 0; i < [self.accounts count]; i++) {
        if ([account.type isEqualToString:[self.accounts objectAtIndex:i]]) {
            [self.accounts removeObjectAtIndex:i];
            i--;
        }
    }
    
    [self.accounts addObject:account];
    [self serialized];
    [GCConfigurationFile write:self];
}

- (void)removeAllAccounts
{
    [self.accounts removeAllObjects];
    [self serialized];
    [GCConfigurationFile write:self];
}

- (void)update
{
    NSURLRequest *request = [NSURLRequest requestWithURL:[self configurationURL]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue currentQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        
        if (!error) {
            NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
            if (!error) {
                [self populate:configuration];
            }
        }
    }];
}

@end
