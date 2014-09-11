//
//  NSURL+ReformattingHelpers.m
//  TenMoves
//
//  Created by David Pedersen on 11/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "NSURL+ReformattingHelpers.h"
#import "NSString+RegExpHelpers.h"

@implementation NSURL (ReformattingHelpers)

- (NSURL *)URLWithoutRootToDocumentsDirectory {
    NSString *currentPath = self.absoluteString;
    NSString *newPath = [currentPath stringWithPatternRemoved:@".*documents/"];
    return [NSURL URLWithString:newPath];
}

@end
