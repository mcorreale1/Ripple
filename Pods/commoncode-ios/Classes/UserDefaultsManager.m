//
//  UserDefaultsManager.m
//  Helpers
//
//  Created by Maxim Soloviev on 02/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import "UserDefaultsManager.h"

@implementation UserDefaultsManager

- (instancetype)initWithKeyNamePrefix:(NSString *)keyNamePrefix
{
    self = [super init];
    if (self) {
        self.keyNamePrefix = keyNamePrefix;
    }
    return self;
}

- (void)setObject:(id)obj forKey:(NSString *)key
{
    if (!key) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setObject:obj forKey:[self keyExtended:key]];
}

- (id)objectForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[self keyExtended:key]];
}

- (NSString *)stringForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:[self keyExtended:key]];
}

- (void)setBool:(BOOL)val forKey:(NSString *)key
{
    if (!key) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] setBool:val forKey:[self keyExtended:key]];
}

- (BOOL)boolForKey:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[self keyExtended:key]];
}

- (void)removeObjectForKey:(NSString *)key
{
    if (!key) {
        return;
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:[self keyExtended:key]];
}

- (NSString *)keyExtended:(NSString *)key
{
    return self.keyNamePrefix ? [self.keyNamePrefix stringByAppendingString:key] : key;
}

@end
