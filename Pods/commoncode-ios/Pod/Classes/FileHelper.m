//
//  FileHelper.m
//  Helpers
//
//  Created by Maxim Soloviev on 08/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "FileHelper.h"

@implementation FileHelper

+ (NSString *)getFilePathInTempFolder:(NSString *)fileName
{
    NSString *tempPath = NSTemporaryDirectory();
    NSString *filePath = [tempPath stringByAppendingPathComponent:fileName];
    return filePath;
}

+ (NSString *)getFilePathInCacheFolder:(NSString *)fileName
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if (paths.count > 0) {
        NSString *filePath = [paths[0] stringByAppendingPathComponent:fileName];
        return filePath;
    }
    return nil;
}

@end
