//
//  UIView+Mask.m
//  Guitarability
//
//  Created by Maxim Soloviev on 30/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "UIView+Mask.h"

@implementation UIView (Mask)

- (void)addCenteredMaskWithRadius:(CGFloat)radius
{
    UIBezierPath *innerCirclePath = [self innerCirclePathWithRadius:radius];
    
    CAShapeLayer *innerCircleLayer = [CAShapeLayer layer];
    innerCircleLayer.path = innerCirclePath.CGPath;
    innerCircleLayer.fillColor = [UIColor whiteColor].CGColor;
    self.layer.mask = innerCircleLayer;
}

- (void)addCenteredMaskWithRadius:(CGFloat)radius innerBorderColor:(UIColor *)borderColor
{
    [self addCenteredMaskWithRadius:radius];

    UIBezierPath *innerCirclePath = [self innerCirclePathWithRadius:radius];
    CAShapeLayer *innerCircleLayer = [CAShapeLayer layer];
    innerCircleLayer.path = innerCirclePath.CGPath;
    innerCircleLayer.strokeColor = borderColor.CGColor;
    innerCircleLayer.lineWidth = 2;
    innerCircleLayer.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:innerCircleLayer];
}

- (UIBezierPath*)innerCirclePathWithRadius:(CGFloat)radius
{
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    CGRect maskRect = CGRectMake(center.x - radius, center.y - radius, radius * 2, radius * 2);
    
    UIBezierPath *innerCirclePath = [UIBezierPath bezierPathWithRoundedRect:maskRect
                                                               cornerRadius:radius];
    return innerCirclePath;
}

- (void)addRoundedRectMaskWithRadius:(CGFloat)radius
{
    self.layer.cornerRadius = radius;
}

- (void)addTopRoundCornersMaskWithRadius:(CGFloat)radius
{
    CGRect maskRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height + radius);
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = maskRect;
    maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    maskLayer.cornerRadius = radius;
    self.layer.mask = maskLayer;
}

- (void)addBottomRoundCornersMaskWithRadius:(CGFloat)radius
{
    CGRect maskRect = CGRectMake(0, -radius, self.bounds.size.width, self.bounds.size.height + radius);
    CALayer *maskLayer = [CALayer layer];
    maskLayer.frame = maskRect;
    maskLayer.backgroundColor = [UIColor whiteColor].CGColor;
    maskLayer.cornerRadius = radius;
    self.layer.mask = maskLayer;
}

- (void)removeMask
{
    self.layer.cornerRadius = 0;
    self.layer.mask = nil;
}

@end
