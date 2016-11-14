//
//  UIView+ExtendedView.h
//  Helpers
//
//  Created by Maxim Soloviev on 08/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extended)

@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;

@property (nonatomic, readonly) CGFloat centerX;
@property (nonatomic, readonly) CGFloat centerY;

@property (nonatomic, readonly) CGFloat halfWidth;
@property (nonatomic, readonly) CGFloat halfHeight;

@property (nonatomic, readonly) CGFloat topOffset;
@property (nonatomic, readonly) CGFloat leftOffset;

- (float)distanceToX:(float)x;
- (float)distanceToY:(float)y;

- (void) removeAllSubviews;
- (void) removeAllGestureRecognizers;

- (void) resizeToHeight:(int)height;
- (void) resizeToWidth:(int)width;

- (void) centerizeAndResize;
- (void) centerizeWithNewWidth:(float)width andHeight:(float)height;

- (void) centerize;
- (void) horizontalCenterize;
- (void) verticalCenterize;

- (void)toBottom;

- (void)addSubview:(UIView *)subview topOffset:(CGFloat)topOffset rightOffset:(CGFloat)rightOffset bottomOffset:(CGFloat)bottomOffset leftOffset:(CGFloat)leftOffset;

@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat borderWidth;
@property (nonatomic, assign) UIColor *borderColor;

@end
