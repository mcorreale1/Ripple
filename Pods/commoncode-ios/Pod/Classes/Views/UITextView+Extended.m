//
//  UITextView+Extended.m
//  Guitarability
//
//  Created by Alexander Kurbanov on 09.12.15.
//  Copyright © 2015 Guitarability. All rights reserved.
//

#import "UITextView+Extended.h"

@implementation UITextView (Extended)

- (void)verticallyCenterizeText
{
    UITextView *textView = self;
    CGFloat topOffset = (textView.bounds.size.height - textView.contentSize.height * textView.zoomScale) / 2.0;
    topOffset = topOffset < 0 ? 0 : topOffset;
    textView.contentOffset = CGPointMake(0, -topOffset);
}

@end
