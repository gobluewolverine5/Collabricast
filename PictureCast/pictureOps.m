//
//  pictureOps.m
//  PictureCast
//
//  Created by Evan Hsu on 2/18/14.
//  Copyright (c) 2014 EECS 441. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "pictureOps.h"
#import "AppDelegate.h"

@implementation pictureOps {
    NSString *filename;
    CGFloat width;
    CGFloat height;
}


- (id) init
{
    if (self = [super init]) {
        filename = [[NSString alloc] init];
        width = 0;
        height = 0;
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

- (UIImage *) saveImage:(NSDictionary *)info highQuality:(CGFloat)imageQuality
{
 
    NSLog(@"info: %@", info);
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];

    filename = [NSString stringWithFormat:@"mediacast%@.%@",
                              [self getPictureID:[url absoluteString]], @"jpg"];

   
    NSFileManager *file_manager = [NSFileManager defaultManager];
    AppDelegate *app_delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *file_path = [[app_delegate cacheURL] stringByAppendingPathComponent:filename];
   
    UIImage *image;
    ALAssetRepresentation *rep = [info objectForKey:@"assetRep"];
    image = [UIImage imageWithCGImage:[rep fullScreenImage]
                                scale:1.0f
                          orientation:(UIImageOrientation)[rep orientation]];

    NSData *imageData = UIImageJPEGRepresentation(image, imageQuality);
    width   = image.size.width;
    height  = image.size.height;
    if ([file_manager fileExistsAtPath:file_path]) {
        NSLog(@"Image already exists");
        return image;
    }
    if ([file_manager createFileAtPath:file_path contents:imageData attributes:nil]) {
        NSLog(@"Successfully wrote image file");
    } else {
        NSLog(@"Failed write image file");
    }

    return image;
}

- (BOOL)saveImageChange:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    AppDelegate *app_delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *file_path = [[app_delegate cacheURL] stringByAppendingPathComponent:filename];
    NSFileManager *file_manager = [NSFileManager defaultManager];
    if ([file_manager createFileAtPath:file_path contents:imageData attributes:nil]) {
        NSLog(@"Successfully wrote image file");
        return TRUE;
    } else {
        NSLog(@"Failed write image file");
        return FALSE;
    }
}

- (UIImage *)fixOrientation:(UIImageOrientation)orientation imageFile:(UIImage *)image
{
    return image;
}

- (NSString *)returnFileName
{
    return filename;
}

- (NSString *)returnFileURL
{
    UInt16 port_number = [(AppDelegate *)[[UIApplication sharedApplication]delegate]port_number];
    NSURL *url = [[NSURL alloc]initWithString:[NSString stringWithFormat:@"http://%@:%hu/%@",
                                                                        [self getIPAddress], port_number,
                                                                        filename]];
    return [url absoluteString];
}

- (BOOL) clearCache
{
    BOOL allDeleted = TRUE;
    NSFileManager *fileManager  = [NSFileManager defaultManager];
    AppDelegate *app_delegate   = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    NSString *saveDirectory     = [app_delegate cacheURL];
    NSArray *cacheFiles         = [fileManager contentsOfDirectoryAtPath:saveDirectory error:nil];
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

- (CGFloat)returnWidth
{
    return width;
}

- (CGFloat)returnHeight
{
    return height;
}

- (NSString *)getIPAddress {
    
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
    
}
@end
