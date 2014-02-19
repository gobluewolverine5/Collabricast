//
//  pictureOps.h
//  PictureCast
//
//  Created by Evan Hsu on 2/18/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface pictureOps : NSObject

- (NSString *)getPictureID:(NSString *)urlString;
- (UIImage *)saveImage:(NSDictionary *)info;
- (UIImage *)fixOrientation:(UIImageOrientation)orientation
                  imageFile:(UIImage *)image;
- (NSString *)returnFileName;

- (BOOL)clearCache;

@end
