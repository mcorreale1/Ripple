//
//  UIImageView+MediaThumbnail.m
//  Guitarability
//
//  Created by Maxim Soloviev on 05/11/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "UIImageView+MediaThumbnail.h"
#import <AVFoundation/AVFoundation.h>

@implementation UIImageView (MediaThumbnail)

- (void)loadThumbnailForMediaUrl:(NSString *)mediaUrl
{
    __weak typeof (self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVAsset *asset = [AVAsset assetWithURL:[NSURL URLWithString:mediaUrl]];
        AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
        CMTime time = CMTimeMake(1, 1);
        NSError *err;
        CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:&err];
        
        if (!err) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof (weakSelf) strongSelf = weakSelf;
                if (strongSelf) {
                    UIImage *thumbImage = [UIImage imageWithCGImage:imageRef];
                    self.image = thumbImage;
                }
                CGImageRelease(imageRef);
            });
        }
    });
}

@end
