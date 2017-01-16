//
//  Macro.h
//  Helpers
//
//  Created by Maxim Soloviev on 22/12/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#ifndef Helpers_Macro_h
#define Helpers_Macro_h

#define ONE_PIXEL   1.0f / [UIScreen mainScreen].scale

#define UIColorFromHex(hexValue) \
[UIColor colorWithRed:((float)((0x ## hexValue & 0xFF0000) >> 16))/255.0 \
                green:((float)((0x ## hexValue & 0x00FF00) >>  8))/255.0 \
                 blue:((float)((0x ## hexValue & 0x0000FF) >>  0))/255.0 \
                alpha:1.0]

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
#define fmore(a, b) (a - b) > ((fabs(a) < fabs(b) ? fabs(b) : fabs(a)) * FLT_EPSILON)

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && fequal(SCREEN_MAX_LENGTH, 480.0))
#define IS_IPHONE_5 (IS_IPHONE && fequal(SCREEN_MAX_LENGTH, 568.0))
#define IS_IPHONE_6 (IS_IPHONE && fequal(SCREEN_MAX_LENGTH, 667.0))
#define IS_IPHONE_6P (IS_IPHONE && fequal(SCREEN_MAX_LENGTH, 736.0))

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define DECLARE_SHARED_INSTANCE_FOR_TYPE(type) \
+ (type *)sharedInstance;

#define IMPLEMENT_SHARED_INSTANCE_USING_BLOCK(block) \
    static dispatch_once_t pred = 0; \
    __strong static id _sharedObject = nil; \
    dispatch_once(&pred, ^{ \
        _sharedObject = block(); \
    }); \
    return _sharedObject; \

#define IMPLEMENT_SHARED_INSTANCE_FOR_TYPE(type) \
+ (type *)sharedInstance \
{ \
    IMPLEMENT_SHARED_INSTANCE_USING_BLOCK(^{ \
        return [self new]; \
    }); \
}

#define USER_DEFAULTS [NSUserDefaults standardUserDefaults]

#define NSLS(str) NSLocalizedString(str, nil)

#define ADD_OBSERVER(notification, func) \
[[NSNotificationCenter defaultCenter] addObserver:self \
                                         selector:@selector(func) \
                                             name:notification \
                                           object:nil];

#define REMOVE_ALL_OBSERVERS \
[[NSNotificationCenter defaultCenter] removeObserver:self];

#define REMOVE_OBSERVER(notification) \
[[NSNotificationCenter defaultCenter] removeObserver:self name:notification object:nil];

#define POST_NOTIFICATION(notification) \
POST_NOTIFICATION_FROM_SENDER(notification, nil)

#define POST_NOTIFICATION_FROM_SENDER(notification, sender) \
[[NSNotificationCenter defaultCenter] postNotificationName:notification object:sender];

#define DISPATCH_SYNC_IN_MAIN_THREAD_SAFE(block)\
if ([NSThread isMainThread]) {\
    block();\
} else {\
    dispatch_sync(dispatch_get_main_queue(), block);\
}

#define CLAMP(x, low, high)  (((x) > (high)) ? (high) : (((x) < (low)) ? (low) : (x)))

#define NON_NIL_STRING(x) x ? x : @""

#define SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING(code) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
code \
_Pragma("clang diagnostic pop") \

#endif
