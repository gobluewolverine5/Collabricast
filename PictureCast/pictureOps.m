//
//  pictureOps.m
//  PictureCast
//
//  Created by Evan Hsu on 2/18/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

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
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    image = [self fixOrientation:[image imageOrientation] imageFile:image];
    if ([file_manager fileExistsAtPath:file_path]) {
        NSLog(@"Image already exists");
        return image;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.7);
   
    if ([file_manager createFileAtPath:file_path contents:imageData attributes:nil]) {
        NSLog(@"Successfully wrote image file");
    } else {
        NSLog(@"Failed write image file");
    }
    
    
    return image;
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
