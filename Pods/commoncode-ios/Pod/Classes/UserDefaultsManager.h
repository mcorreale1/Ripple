//
//  UserDefaultsManager.h
//  Helpers
//
//  Created by Maxim Soloviev on 02/10/15.
//  Copyright © 2015 Omega-R. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserDefaultsManager : NSObject

- (instancetype)initWithKeyNamePrefix:(NSString *)keyNamePrefix;

@property (nonatomic, strong) NSString *keyNamePrefix;

- (void)setObject:(id)obj forKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;

- (void)setBool:(BOOL)val forKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;

- (void)removeObjectForKey:(NSString *)key;

@end
