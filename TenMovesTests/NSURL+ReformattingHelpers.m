//
//  NSURL+ReformattingHelpers.m
//  TenMoves
//
//  Created by David Pedersen on 11/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "NSURL+ReformattingHelpers.h"
#import "AppDelegate.h"

@interface NSURL_ReformattingHelpers : XCTestCase

@end

@implementation NSURL_ReformattingHelpers

- (void)testExample {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSURL *url = [appDelegate applicationDocumentsDirectory];
    NSURL *formatted = [url URLWithoutRootToDocumentsDirectory];
    XCTAssert([formatted.absoluteString isEqualToString:@""]);
}

@end
