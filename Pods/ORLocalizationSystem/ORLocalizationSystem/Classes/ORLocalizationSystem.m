//
//  LocalizationSystem.m
//  MobileConcierge
//
//  Created by Evgeny on 16/02/16.
//  Copyright © 2016 omega-r. All rights reserved.
//

#import "ORLocalizationSystem.h"

static ORLocalizationSystem *instance = nil;


@interface ORLocalizationSystem ()

@property (nonatomic, strong) NSBundle *bundle;
@property (nonatomic, strong) NSString *currentLanguage;

@end

@implementation ORLocalizationSystem

+ (ORLocalizationSystem *)sharedInstanse
{
    if (!instance) {
        instance = [[ORLocalizationSystem alloc] init];
        [instance setLanguage:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]];
    }
    
    return instance;
}

- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment
{
    return [self.bundle localizedStringForKey:key value:comment table:nil];
}

- (void)setLanguage:(NSString *)language
{
    if (self.currentLanguage && [language isEqualToString:self.currentLanguage])
        return;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj"];
    self.currentLanguage = language;
    
    if (path == nil) {
        [self resetLocalization];
    } else {
        self.bundle = [NSBundle bundleWithPath:path];
    }
}

- (NSString *)getLanguage
{
    if (!self.currentLanguage) {
        NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
        self.currentLanguage = [languages objectAtIndex:0];
        
        NSString *path = [[NSBundle mainBundle] pathForResource:_currentLanguage ofType:@"lproj"];
        
        if (path == nil) {
            [self resetLocalization];
            self.currentLanguage = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
        }
    }
    
    return self.currentLanguage;
}

- (void)resetLocalization
{
    self.currentLanguage = nil;
}

@end
