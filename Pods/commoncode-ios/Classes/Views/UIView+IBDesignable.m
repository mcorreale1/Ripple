//
//  UIView+IBDesignable.m
//  Guitarability
//
//  Created by Maxim Soloviev on 26/12/15.
//  Copyright © 2015 Guitarability. All rights reserved.
//

#import "UIView+IBDesignable.h"

@implementation UIView (IBDesignable)

- (void)loadViewFromNibAndAddAsSubview
{
    UIView *v = [self loadViewFromNib];
    v.frame = self.bounds;
    v.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:v];
}

- (UIView *)loadViewFromNib
{
    UIView *v = [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([self class]) owner:self options:nil].firstObject;
    return v;
}

@end
