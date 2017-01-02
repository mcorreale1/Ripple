//
//  UIView+ExtendedView.m
//  Helpers
//
//  Created by Maxim Soloviev on 08/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "UIView+Extended.h"

@implementation UIView (Extended)

#pragma mark - Size and position

- (void) setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat) x {
    return self.frame.origin.x;
}

- (void) setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat) y {
    return self.frame.origin.y;
}

- (void) setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat) width {
    return self.frame.size.width;
}

- (void) setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat) height {
    return self.frame.size.height;
}

- (CGFloat) centerX
{
    return self.x + self.halfWidth;
}
- (CGFloat) centerY
{
    return self.y + self.halfHeight;
}

- (CGFloat) halfWidth
{
    return self.width / 2.0;
}

- (CGFloat) halfHeight
{
    return self.height / 2.0;
}

- (CGFloat) topOffset {
    return self.y + self.height;
}

- (CGFloat) leftOffset {
    return self.x + self.width;
}


#pragma mark - Working with subviews

- (void) removeAllSubviews {
    for (UIView *view in self.subviews) {
        [view removeFromSuperview];
        [view removeAllGestureRecognizers];
    }
}

- (void) removeAllGestureRecognizers {
    for (UIGestureRecognizer *gestureRecognizer in self.gestureRecognizers) {
        [self removeGestureRecognizer:gestureRecognizer];
    }
}

- (void)addSubview:(UIView *)subview topOffset:(CGFloat)topOffset rightOffset:(CGFloat)rightOffset bottomOffset:(CGFloat)bottomOffset leftOffset:(CGFloat)leftOffset
{
    [self addSubview:subview];
    subview.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeTop multiplier:1 constant:topOffset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeTrailing relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeTrailing multiplier:1 constant:rightOffset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeBottom multiplier:1 constant:bottomOffset]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:subview attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual
                                                        toItem:self attribute:NSLayoutAttributeLeading multiplier:1 constant:leftOffset]];
    [self layoutSubviews];
}


#pragma mark - Some calculation

- (float)distanceToX:(float)x
{
    if (x >= self.x && x <= self.leftOffset) {
        return 0;
    }
    if (x < self.x) {
        return self.x - x;
    }
    return x - self.leftOffset;
}

- (float)distanceToY:(float)y
{
    if (y >= self.y && y <= self.topOffset) {
        return 0;
    }
    if (y < self.y) {
        return self.y - y;
    }
    return y - self.topOffset;
}


#pragma mark - Centerizing and resizing

- (void) centerize {
    [self verticalCenterize];
    [self horizontalCenterize];
}

- (void) horizontalCenterize {
    self.x = (self.superview.width - self.width) / 2.0;
}

- (void) verticalCenterize {
    self.y = (self.superview.height - self.height) / 2.0;
}

- (void) resizeToHeight:(int) height {
    if (!self.height) {
        return;
    }
    float sizeFactor = self.width / self.height;
    
    self.height = height;
    self.width = height * sizeFactor;
}

- (void) resizeToWidth:(int) width {
    if (!self.width) {
        return;
    }
    float sizeFactor = self.width / self.height;
    
    self.width = width;
    self.height = width / sizeFactor;
}

- (void) centerizeAndResize {
    [self centerizeWithNewWidth:self.width andHeight:self.height];
}


- (void) centerizeWithNewWidth:(float)width andHeight:(float)height {
    float parentWidth = self.superview.width;
    float parentHeight = self.superview.height;
    
    float factor;
    
    if (width > parentWidth) {
        factor = width / height;
        width = parentWidth;
        height = width / factor;
    }
    
    if (height > parentHeight) {
        factor = width / height;
        height = parentHeight;
        width = height * factor;
    }
    
    CGRect frame;
    
    frame.size.width = width;
    frame.size.height = height;
    frame.origin.x = (parentWidth - width) / 2;
    frame.origin.y = (parentHeight - height) / 2;
    self.frame = frame;
}

- (void)toBottom
{
    self.y = self.superview.height - self.height;
}

- (CGFloat)cornerRadius {
    return self.layer.cornerRadius;
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    self.layer.cornerRadius = cornerRadius;
}

- (CGFloat)borderWidth {
    return self.layer.borderWidth;
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (UIColor *)borderColor {
    return [UIColor colorWithCGColor:self.layer.borderColor];
}

- (void)setBorderColor:(UIColor *)borderColor {
    self.layer.borderColor = borderColor.CGColor;
}

@end
