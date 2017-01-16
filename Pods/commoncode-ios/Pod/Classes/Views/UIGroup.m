//
//  UIGroup.m
//  Helpers
//
//  Created by Maxim Soloviev on 06.04.15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "UIGroup.h"

@implementation UIGroup

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // If one of our subviews wants it, return YES
    for (UIView *subview in self.subviews)
    {
        if (!subview.hidden)
        {
            CGPoint pointInSubview = [subview convertPoint:point fromView:self];
            if ([subview pointInside:pointInSubview withEvent:event])
            {
                return YES;
            }
        }
    }
    // otherwise return NO, as if userInteractionEnabled were NO
    return NO;
}

@end
