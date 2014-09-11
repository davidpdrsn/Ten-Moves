//
//  NSString+RegExpHelpers.m
//  TenMoves
//
//  Created by David Pedersen on 11/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSString+RegExpHelpers.h"

@interface NSString_RegExpHelpers : XCTestCase

@end

@implementation NSString_RegExpHelpers

- (void)testReplacingWithAPattern {
    NSString *path = @"file:///some/path/that/i/dont/control/documents/file.txt";
    NSString *result = [path stringWithPatternReplacedBy:@".*documents" replacement:@"root"];
    XCTAssert([result isEqualToString:@"root/file.txt"]);
}

- (void)testRemovingPattern {
    NSString *path = @"file:///some/path/that/i/dont/control/documents/file.txt";
    NSString *result = [path stringWithPatternRemoved:@".*documents"];
    XCTAssert([result isEqualToString:@"/file.txt"]);
}

@end
