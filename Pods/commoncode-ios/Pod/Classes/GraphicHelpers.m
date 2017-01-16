//
//  GraphicHelpers.m
//  Helpers
//
//  Created by Maxim Soloviev on 08/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "GraphicHelpers.h"

@implementation GraphicHelpers

+ (CGRect)rectWithSameCenter:(CGRect)r newWidth:(CGFloat)newWidth newHeight:(CGFloat)newHeight
{
    if (CGRectIsNull(r)) {
        return CGRectNull;
    }
    
    if (newWidth < 0) {
        newWidth = 0;
    }
    if (newHeight < 0) {
        newHeight = 0;
    }
    
    CGFloat insetW = (CGRectGetWidth(r) - newWidth) / 2;
    CGFloat insetH = (CGRectGetHeight(r) - newHeight) / 2;
    return CGRectInset(r, insetW, insetH);
}

@end
