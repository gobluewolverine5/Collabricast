//
//  pictureOps.m
//  PictureCast
//
//  Created by Evan Hsu on 2/18/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "pictureOps.h"
#import "AppDelegate.h"

@implementation pictureOps {
    NSString *filename;
}


- (id) init
{
    if (self = [super init]) {
        filename = [[NSString alloc] init];
    }
    return self;
}

- (NSString *) getPictureID:(NSString *)urlString
{
    NSRange id_is = [urlString rangeOfString:@"id="];
    NSRange ext_is = [urlString rangeOfString:@"&ext="];
    NSRange range = { id_is.location + 3, ext_is.location - id_is.location - 3 };
    return [urlString substringWithRange:range];
}

- (UIImage *) saveImage:(NSDictionary *)info
{
  
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];

    filename = [NSString stringWithFormat:@"mediacast%@.%@",
                              [self getPictureID:[url absoluteString]], @"jpg"];

   
    NSFileManager *file_manager = [NSFileManager defaultManager];
    AppDelegate *app_delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *file_path = [[app_delegate cacheURL] stringByAppendingPathComponent:filename];
   
    UIImage *image;
    if ([[info objectForKey:@"UIImagePickerControllerMediaType"] isEqualToString:ALAssetTypePhoto]) {
        ALAssetRepresentation *rep = [info objectForKey:@"assetRep"];
        image = [UIImage imageWithCGImage:[rep fullResolutionImage]
                                    scale:1.0f
                              orientation:[rep orientation]];
    } else {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
    image = nil;
    if ([file_manager fileExistsAtPath:file_path]) {
        NSLog(@"Image already exists");
        return [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    if ([file_manager createFileAtPath:file_path contents:imageData attributes:nil]) {
        NSLog(@"Successfully wrote image file");
    } else {
        NSLog(@"Failed write image file");
    }

    return [info objectForKey:UIImagePickerControllerOriginalImage];
}

- (UIImage *)fixOrientation:(UIImageOrientation)orientation imageFile:(UIImage *)image
{
    return image;
}

- (NSString *)returnFileName
{
    return filename;
}

- (BOOL) clearCache
{
    BOOL allDeleted = TRUE;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    AppDelegate *app_delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *saveDirectory = [app_delegate cacheURL];
    NSArray *cacheFiles = [fileManager contentsOfDirectoryAtPath:saveDirectory error:nil];
    for (NSString *file in cacheFiles) {
        if ([file rangeOfString:@"mediacast"].location != NSNotFound) {
            NSLog(@"images being deleted: %@", file);
            if (![fileManager removeItemAtPath:[saveDirectory stringByAppendingPathComponent:file]
                                        error:nil]) {
                NSLog(@"error");
                allDeleted = FALSE;
            }
        }
    }
    return allDeleted;
}
@end
