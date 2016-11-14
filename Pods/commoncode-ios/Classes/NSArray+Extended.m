//
//  NSArray+Extended.m
//  Guitarability
//
//  Created by Alexander Kurbanov on 30.04.15.
//  Copyright (c) 2015 Guitarability. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Macro.h"
#import "NSArray+Extended.h"

@implementation NSArray (Extended)

- (id)firstObjectWithSelector:(SEL)selector notEqualTo:(NSInteger)compare
{
    for (id object in self) {
        if ([object respondsToSelector:selector] && (NSInteger)SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([object performSelector:selector]) != compare) {
            return object;
        }
    }
    return nil;
}

- (id)firstObjectWithPositiveResult:(SEL)selector
{
    for (id object in self) {
        if ([object respondsToSelector:selector] && SUPPRESS_PERFORM_SELECTOR_LEAK_WARNING([object performSelector:selector])) {
            return object;
        }
    }
    return nil;
}

- (id)safeItemAtIndexPath:(NSIndexPath *)indexPath
{
    id result = nil;
    if (indexPath.row < self.count) {
        result = [self objectAtIndex:indexPath.row];
    }
    return result;
}

- (id)safeItemAtIndex:(NSUInteger)index
{
    id result = nil;
    if (index < self.count) {
        result = [self objectAtIndex:index];
    }
    return result;
}

- (NSArray *)arrayByDeletingObjectsFromArray:(NSArray *)otherArray
{
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:self];
    for (id obj in otherArray) {
        [mArray removeObject:obj];
    }
    return [mArray copy];
}

@end
