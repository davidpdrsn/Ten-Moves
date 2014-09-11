//
//  NSString+RegExpHelpers.m
//  TenMoves
//
//  Created by David Pedersen on 11/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "NSString+RegExpHelpers.h"

@implementation NSString (RegExpHelpers)

- (NSString *)stringwithPatternReplacedBy:(NSString *)pattern replacement:(NSString *)replacement {
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:self
                                                               options:0
                                                                 range:NSMakeRange(0, self.length)
                                                          withTemplate:replacement];
    
    return modifiedString;
}

- (NSString *)stringwithPatternRemoved:(NSString *)pattern {
    return [self stringwithPatternReplacedBy:pattern replacement:@""];
}

@end
