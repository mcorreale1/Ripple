//
//  Helpers.m
//  Helpers
//
//  Created by Maxim Soloviev on 08/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "CommonHelpers.h"

@implementation CommonHelpers

+ (void)hideKeyboard
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
}

+ (void)setupInsetsForScrollView:(UIScrollView *)scrollView whenKeyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    UIEdgeInsets currentInsets = scrollView.contentInset;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(currentInsets.top, currentInsets.left, kbSize.height, currentInsets.right);
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
}

+ (void)setupInsetsForScrollView:(UIScrollView *)scrollView whenKeyboardWillBeHidden:(NSNotification*)aNotification
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.3f animations:^{
            UIEdgeInsets currentInsets = scrollView.contentInset;
            UIEdgeInsets contentInsets = UIEdgeInsetsMake(currentInsets.top, currentInsets.left, 0, currentInsets.right);
            scrollView.contentInset = contentInsets;
            scrollView.scrollIndicatorInsets = contentInsets;
        }];
    });
}

+ (void)setupBottomConstraint:(NSLayoutConstraint *)constraint inSuperview:(UIView *)superview whenKeyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    constraint.constant = kbSize.height;
    [superview layoutIfNeeded];
}

+ (void)setupBottomConstraint:(NSLayoutConstraint *)constraint whenKeyboardWillBeHidden:(NSNotification*)aNotification
{
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [UIView animateWithDuration:.3f animations:^{
            constraint.constant = 0;
        }];
    });
}

+ (void)enableNavButtons:(BOOL)enable inVC:(UIViewController *)vc
{
    vc.navigationItem.leftBarButtonItem.enabled = enable;
    vc.navigationItem.rightBarButtonItem.enabled = enable;
}

+ (void)makeBarButtonTransparentForDisabledState:(UIBarButtonItem *)item
{
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithWhite:1 alpha:0.5]} forState:UIControlStateDisabled];
}

+ (void)displayContentController: (UIViewController*)contentVC inParent: (UIViewController *)parentVC andView:(UIView *)view
{
    [parentVC addChildViewController:contentVC];
    
    UIView *parentView = view ? view : parentVC.view;
    
    contentVC.view.frame = parentView.frame;
    [parentView addSubview:contentVC.view];
    [contentVC didMoveToParentViewController:parentVC];
}

+ (void)removeContentController: (UIViewController*) content
{
    if (content)
    {
        [content.view removeFromSuperview];
        [content removeFromParentViewController];
        content = nil;
    }
}

@end
