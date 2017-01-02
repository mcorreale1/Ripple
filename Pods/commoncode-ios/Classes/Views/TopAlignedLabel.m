//
//  TopAlignedLabel.m
//  Guitarability
//
//  Created by Alexander Kurbanov on 24.07.15.
//  Copyright (c) 2015 Guitarability. All rights reserved.
//

// (Note): See http://stackoverflow.com/questions/28605341/vertically-align-text-within-a-uilabel-note-using-autolayout

#import "TopAlignedLabel.h"

@implementation TopAlignedLabel

- (void)drawTextInRect:(CGRect)rect
{
    if (self.text) {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
        attributes[NSFontAttributeName] = self.font;
        
        NSRange range = NSMakeRange(0, 0);
        NSParagraphStyle *paragraphStyle = [self.attributedText attribute:NSParagraphStyleAttributeName atIndex:NSMaxRange(range) effectiveRange:&range];
        if (paragraphStyle) {
            NSMutableParagraphStyle *mutableParagraphStyle = [[NSMutableParagraphStyle alloc] init];
            mutableParagraphStyle.lineSpacing = paragraphStyle.lineSpacing;
            attributes[NSParagraphStyleAttributeName] = mutableParagraphStyle;
        }
        
        CGSize labelStringSize = [self.text boundingRectWithSize:CGSizeMake(ceilf(self.frame.size.width), CGFLOAT_MAX)
                                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                      attributes:attributes
                                                         context:nil].size;
        [super drawTextInRect:CGRectMake(0, 0, ceilf(self.frame.size.width), ceilf(labelStringSize.height))];
    } else {
        [super drawTextInRect:rect];
    }
}

@end
