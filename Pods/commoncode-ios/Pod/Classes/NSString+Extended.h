//
//  NSString+Extended.h
//  Guitarability
//
//  Created by Alexander Kurbanov on 13.04.15.
//  Copyright (c) 2015 Guitarability. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Extended)

+ (BOOL)isNilOrEmpty:(NSString *)string;
+ (NSString *)safeString:(NSString *)string;
- (BOOL)caseInsensetiveContainsString:(NSString *)string;

+ (NSString *)secondsToHHMMSS:(NSTimeInterval)seconds discardZeroHours:(BOOL)discardZeroHours;
+ (NSString *)secondsToMM:(NSTimeInterval)seconds;
- (NSString *)tagFromString;
- (NSString *)stringWithoutWhitespaces;
- (NSString *)stringWithCapitalizedFirstLetter;

- (NSString *)stringWithoutPrefix:(NSString *)prefix;

- (NSString *)truncatedStringWithEllipsisIfLongerThan:(NSUInteger)limit;

@end


@interface NSMutableString (Extended)

- (void)appendLine;

@end
