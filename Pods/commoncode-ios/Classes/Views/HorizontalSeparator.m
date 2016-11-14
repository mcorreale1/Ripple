//
//  HorizontalOnePixelSeparator.m
//  Helpers
//
//  Created by Maxim Soloviev on 17/07/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "HorizontalSeparator.h"

@implementation HorizontalSeparator

#pragma mark - View lifecycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        // Set height of exactly one pixel if this view is using constraints
        if (constraint.firstAttribute == NSLayoutAttributeHeight) {
            constraint.constant /= [UIScreen mainScreen].scale;
        }
    }
}

@end
