//
//  NSArray+Extended.h
//  Guitarability
//
//  Created by Alexander Kurbanov on 30.04.15.
//  Copyright (c) 2015 Guitarability. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Extended)

- (id)firstObjectWithSelector:(SEL)selector notEqualTo:(NSInteger)compare;
- (id)firstObjectWithPositiveResult:(SEL)selector;
- (id)safeItemAtIndexPath:(NSIndexPath *)indexPath;
- (id)safeItemAtIndex:(NSUInteger)index;

- (NSArray *)arrayByDeletingObjectsFromArray:(NSArray *)otherArray;

@end
