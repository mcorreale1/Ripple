/*
Copied and pasted from David Hamrick's blog:

Source: http://www.davidhamrick.com/2011/12/31/Changing-the-UINavigationController-animation-style.html
*/

@interface UINavigationController (Fade)

- (void)pushFadeViewController:(UIViewController *)viewController;
- (void)popFadeViewController;

@end