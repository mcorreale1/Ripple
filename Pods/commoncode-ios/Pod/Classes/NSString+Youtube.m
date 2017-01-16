//
//  NSString+Youtube.m
//  Guitarability
//
//  Created by Maxim Solovyev on 11/11/15.
//  Copyright © 2015 Guitarability. All rights reserved.
//

#import "NSString+Youtube.h"
#import "NSString+Extended.h"

// Note: http://stackoverflow.com/questions/2068344/how-do-i-get-a-youtube-video-thumbnail-from-the-youtube-api

@implementation NSString (Youtube)

- (NSString *)youtubePreviewImageUrlBestQuality
{
    // only use this method if you are sure that the video is of high quality, since this file is not guarenteed to exist
    NSString *result = [self imagePreviewURLWithFileName:@"maxresdefault.jpg"];
    return result;
}

- (NSString *)youtubePreviewImageUrlMediumQuality
{
    NSString *result = [self imagePreviewURLWithFileName:@"mqdefault.jpg"];
    return result;
}

- (NSString *)youtubePreviewImageUrlStandardQuality
{
    NSString *result = [self imagePreviewURLWithFileName:@"sddefault.jpg"];
    return result;
}

- (NSString *)youtubeVideoId
{
    NSString *regexString = @"((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)";
    NSRegularExpression *regExp = [NSRegularExpression regularExpressionWithPattern:regexString
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    
    NSArray *array = [regExp matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (array.count > 0) {
        NSTextCheckingResult *result = array.firstObject;
        return [self substringWithRange:result.range];
    }
    return nil;
}

- (BOOL)isYoutubeUrl
{
    NSString *temp = [self lowercaseString];
    temp = [temp stringWithoutPrefix:@"https://"];
    temp = [temp stringWithoutPrefix:@"http://"];
    temp = [temp stringWithoutPrefix:@"www."];
    temp = [temp stringWithoutPrefix:@"m."];
    
    if ([temp isEqualToString:@"youtube.com"]
        || [temp isEqualToString:@"youtu.be"]
        || [temp hasPrefix:@"youtube.com/"]
        || [temp hasPrefix:@"youtu.be/"])
    {
        return YES;
    }
    return NO;
}


#pragma mark - Helper methods

- (NSString *)imagePreviewURLWithFileName:(NSString *)filename
{
    NSString *result = [NSString stringWithFormat:@"https://img.youtube.com/vi/%@/%@", [self youtubeVideoId], filename];
    return result;
}

@end
