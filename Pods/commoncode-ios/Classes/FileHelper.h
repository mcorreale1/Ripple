//
//  FileHelper.h
//  Helpers
//
//  Created by Maxim Soloviev on 08/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileHelper : NSObject

+ (NSString *)getFilePathInTempFolder:(NSString *)fileName;
+ (NSString *)getFilePathInCacheFolder:(NSString *)fileName;

@end
