//
//  UIView+IBDesignable.h
//  Guitarability
//
//  Created by Maxim Soloviev on 26/12/15.
//  Copyright © 2015 Guitarability. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (IBDesignable)

- (void)loadViewFromNibAndAddAsSubview;
- (UIView *)loadViewFromNib;

@end
