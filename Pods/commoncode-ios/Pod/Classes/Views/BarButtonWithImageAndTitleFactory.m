//
//  BarButtonWithImageAndTitleFactory.m
//  Helpers
//
//  Created by Maxim Soloviev on 08/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "BarButtonWithImageAndTitleFactory.h"
#import "UIImage+ImageWithAlpha.h"

@implementation BarButtonWithImageAndTitleFactory

+ (UIButton *)makeCustomBarButtonWithTitle:(NSString *)title
                                      font:(UIFont *)font
                                     image:(UIImage *)image
                                    target:(id)target
                                    action:(SEL)action
{
    static const CGFloat navBarItemFontSize = 17;
    static const CGFloat navBarItemHighlightedAlpha = 0.25;
    static const CGFloat additionalFrameOutset = 5;
    
    UIButton *customButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customButton.titleLabel.font = font ? font : [UIFont systemFontOfSize:navBarItemFontSize];
    customButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    
    [customButton setImage:image forState:UIControlStateNormal];
    [customButton setImage:[image imageWithAlpha:navBarItemHighlightedAlpha] forState:UIControlStateHighlighted];
    [customButton setTitle:title forState:UIControlStateNormal];
    
    UIColor *titleColor = [UINavigationBar appearance].tintColor;
    [customButton setTitleColor:titleColor forState:UIControlStateNormal];
    [customButton setTitleColor:[titleColor colorWithAlphaComponent:navBarItemHighlightedAlpha] forState:UIControlStateHighlighted];
    [customButton sizeToFit];
    
    customButton.frame = CGRectInset(customButton.frame, -additionalFrameOutset, 0);
    
    CGFloat imgW = image.size.width;
    customButton.imageEdgeInsets = UIEdgeInsetsMake(0, customButton.bounds.size.width - imgW, 0,  0);
    customButton.titleEdgeInsets = UIEdgeInsetsMake(0, -imgW, 0, imgW);
    
    customButton.contentEdgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);
    
    [customButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    return customButton;
}

@end
