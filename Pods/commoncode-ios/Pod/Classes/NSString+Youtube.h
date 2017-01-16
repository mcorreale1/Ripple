//
//  NSString+Youtube.h
//  Guitarability
//
//  Created by Maxim Solovyev on 11/11/15.
//  Copyright © 2015 Guitarability. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Youtube)

- (NSString *)youtubePreviewImageUrlBestQuality;
- (NSString *)youtubePreviewImageUrlMediumQuality;
- (NSString *)youtubePreviewImageUrlStandardQuality;

- (NSString *)youtubeVideoId;
- (BOOL)isYoutubeUrl;

@end
