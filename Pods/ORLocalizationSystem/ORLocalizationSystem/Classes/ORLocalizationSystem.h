//
//  LocalizationSystem.h
//  MobileConcierge
//
//  Created by Evgeny on 16/02/16.
//  Copyright © 2016 omega-r. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ORLocalizationSystem : NSObject

+ (ORLocalizationSystem *)sharedInstanse;
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)comment;
- (void)setLanguage:(NSString *)language;
- (NSString *)getLanguage;

@end
