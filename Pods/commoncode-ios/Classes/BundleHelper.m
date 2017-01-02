//
//  BundleHelper.m
//  Helpers
//
//  Created by Maxim Soloviev on 28/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "BundleHelper.h"

@implementation BundleHelper

+ (NSString *)pathForResourceFile:(NSString *)resFile
{
    NSString *fileName = [[resFile lastPathComponent] stringByDeletingPathExtension];
    NSString *fileType = [resFile pathExtension];
    NSString *resFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:fileType];
    return resFilePath;
}

@end
