//
//  GCPhotoPickerConfiguration.h
//  PhotoPickerPlus-SampleApp
//
//  Created by Aleksandar Trpeski on 10/30/13.
//  Copyright (c) 2013 Chute. All rights reserved.
//

#import "GCConfigurationFile.h"

@interface GCPhotoPickerConfiguration : NSObject <GCConfigurationProtocol>

/**
 URL for the list of services & local_features to be downloaded from.
 */
@property (strong, nonatomic) NSURL             *configurationURL;

/**
 Array used for storing services.
 */
@property (strong, nonatomic) NSArray           *services;

/**
 Array used for storing local services.
 */
@property (strong, nonatomic) NSArray           *localFeatures;

/**
 Setting for loading UIImagePickerControllerOriginalImage for assets from web.
 */
@property (assign, nonatomic) BOOL              loadAssetsFromWeb;

/**
 MutableArray used to store logged accounts.
 */
@property (strong, nonatomic) NSMutableArray    *accounts;

///------------------------
/// @name Adding an account
///------------------------

/**
 Adding an account to an array. It is used for bigger controll for which account is already logged in.
 
 @param account The account that needs to be added to logged accounts.
 
 @warning This method requires `GCAccount` class. Add an `#import "GCAccount.h"` in your header/implementation file.
 */

- (void)addAccount:(GCAccount *)account;

- (void)removeAllAccounts;

- (GCLoginType)loginTypeForString:(NSString *)serviceString;

- (NSString *)loginTypeString:(GCLoginType)loginType;

@end
