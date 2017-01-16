//
//  UIScrollView+DisableDelaysContentTouches.m
//  Helpers
//
//  Created by Maxim Soloviev on 08/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "UIScrollView+DisableDelaysContentTouches.h"

@implementation UIScrollView (DisableDelaysContentTouches)

- (void)disableDelaysContentTouches
{
    self.delaysContentTouches = NO;
    
    for (id subview in self.subviews) {
        if ([subview isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)subview;
            scrollView.delaysContentTouches = NO;
        }
    }
}

@end
