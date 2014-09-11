//
//  NSString+RegExpHelpers.h
//  TenMoves
//
//  Created by David Pedersen on 11/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RegExpHelpers)

- (NSString *)stringwithPatternReplacedBy:(NSString *)pattern replacement:(NSString *)replacement;
- (NSString *)stringwithPatternRemoved:(NSString *)pattern;

@end
