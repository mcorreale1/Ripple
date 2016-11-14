//
//  UIView+Mask.h
//  Guitarability
//
//  Created by Maxim Soloviev on 30/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Mask)

- (void)addCenteredMaskWithRadius:(CGFloat)radius;
- (void)addCenteredMaskWithRadius:(CGFloat)radius innerBorderColor:(UIColor *)borderColor;

- (void)addRoundedRectMaskWithRadius:(CGFloat)radius;
- (void)addTopRoundCornersMaskWithRadius:(CGFloat)radius;
- (void)addBottomRoundCornersMaskWithRadius:(CGFloat)radius;

- (void)removeMask;

@end
