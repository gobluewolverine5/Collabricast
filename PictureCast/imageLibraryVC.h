//
//  imageLibraryVC.h
//  PictureCast
//
//  Created by Evan Hsu on 2/18/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ALAssetsGroup;

@interface imageLibraryVC : UICollectionViewController

@property (nonatomic, strong) ALAssetsGroup *assets_group;
@property (nonatomic, strong) NSMutableArray *asset_array;

@end
