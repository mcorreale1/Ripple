//
//  NSString+Extended.m
//  Guitarability
//
//  Created by Alexander Kurbanov on 13.04.15.
//  Copyright (c) 2015 Guitarability. All rights reserved.
//

#import "NSString+Extended.h"

@implementation NSString (Extended)

+ (BOOL)isNilOrEmpty:(NSString *)string
{
    return (string == nil) || !string.length;
}

+ (NSString *)safeString:(NSString *)string
{
    if (!string) {
        return @"";
    }
    return string;
}

- (BOOL)caseInsensetiveContainsString:(NSString *)string
{
    BOOL result = [self rangeOfString:string options:NSCaseInsensitiveSearch].location != NSNotFound;
    return result;
}

+ (NSString *)secondsToHHMMSS:(NSTimeInterval)seconds discardZeroHours:(BOOL)discardZeroHours
{
    int time = floor(seconds);
    int hh = time / 3600;
    int mm = (time / 60) % 60;
    int ss = time % 60;
    NSString *result = nil;
    if(hh > 0
       || !discardZeroHours)
    {
        result = [NSString stringWithFormat:@"%d:%02i:%02i", hh, mm, ss];
    } else {
        result = [NSString stringWithFormat:@"%02i:%02i", mm, ss];
    }
    return result;
}

+ (NSString *)secondsToMM:(NSTimeInterval)seconds
{
    int time = floor(seconds);
    int mm = (time / 60) % 60;
    NSString *result = [NSString stringWithFormat:@"%i", mm];
    return result;
}

- (NSString *)tagFromString
{
    NSString *result = [@"#" stringByAppendingString:self];
    return result;
}

- (NSString *)stringWithoutWhitespaces
{
    NSString *result = [self stringByReplacingOccurrencesOfString:@" " withString:@""];
    return result;
}

- (NSString *)stringWithCapitalizedFirstLetter
{
    if (!self.length) {
        return self;
    }
    NSString *result = [self stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[self substringToIndex:1] uppercaseString]];
    return result;
}

- (NSString *)stringWithoutPrefix:(NSString *)prefix
{
    if (!self) {
        return self;
    }
    NSRange r = [self rangeOfString:prefix options:NSCaseInsensitiveSearch];
    if (r.location == 0) {
        NSString *result = [self stringByReplacingCharactersInRange:r withString:@""];
        return result;
    }
    return self;
}

- (NSString *)truncatedStringWithEllipsisIfLongerThan:(NSUInteger)limit
{
    NSString *newString = self.length <= limit ? self : [NSString stringWithFormat:@"%@…", [self substringToIndex:limit - 1]];
    return newString;
}

@end



@implementation NSMutableString (Extended)

- (void)appendLine
{
    [self appendString:@"\r\n"];
}

@end
