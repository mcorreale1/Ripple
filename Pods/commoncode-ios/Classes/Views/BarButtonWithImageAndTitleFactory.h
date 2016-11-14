//
//  BarButtonWithImageAndTitleFactory.h
//  Helpers
//
//  Created by Maxim Soloviev on 08/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BarButtonWithImageAndTitleFactory : NSObject

+ (UIButton *)makeCustomBarButtonWithTitle:(NSString *)title
                                      font:(UIFont *)font
                                     image:(UIImage *)image
                                    target:(id)target
                                    action:(SEL)action;

@end
