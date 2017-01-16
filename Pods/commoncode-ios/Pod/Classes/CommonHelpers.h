//
//  Helpers.h
//  Helpers
//
//  Created by Maxim Soloviev on 08/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonHelpers : NSObject

+ (void)hideKeyboard;

+ (void)setupInsetsForScrollView:(UIScrollView *)scrollView whenKeyboardWasShown:(NSNotification*)aNotification;
+ (void)setupInsetsForScrollView:(UIScrollView *)scrollView whenKeyboardWillBeHidden:(NSNotification*)aNotification;

+ (void)setupBottomConstraint:(NSLayoutConstraint *)constraint inSuperview:(UIView *)superview whenKeyboardWasShown:(NSNotification*)aNotification;
+ (void)setupBottomConstraint:(NSLayoutConstraint *)constraint whenKeyboardWillBeHidden:(NSNotification*)aNotification;

+ (void)enableNavButtons:(BOOL)enable inVC:(UIViewController *)vc;
+ (void)makeBarButtonTransparentForDisabledState:(UIBarButtonItem *)item;

+ (void)displayContentController: (UIViewController*)contentVC inParent: (UIViewController *)parentVC andView:(UIView *)view;
+ (void)removeContentController: (UIViewController*) content;

@end
