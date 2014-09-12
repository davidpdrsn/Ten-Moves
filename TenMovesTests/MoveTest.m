//
//  MoveTest.m
//  TenMoves
//
//  Created by David Pedersen on 12/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "TestCaseWithCoreData.h"
#import "Move.h"

@interface MoveTest : TestCaseWithCoreData

@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation MoveTest

- (void)setUp {
    [super setUp];
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateStyle = NSDateFormatterLongStyle;
}

- (void)testUpdatedAtWhenBrandNew {
    Move *move = [Move newManagedObject];

    NSString *updatedAt = [self.formatter stringFromDate:move.updatedAt];
    NSString *now = [self.formatter stringFromDate:[NSDate date]];
    XCTAssert([updatedAt isEqualToString:now]);
}

- (void)testUpdatedAtChangingProperties {
    Move *move = [Move newManagedObject];
    NSDate *inThePast = [NSDate dateWithTimeIntervalSince1970:0];
    move.updatedAt = inThePast;

    move.name = @"a new name";

    NSString *updatedAt = [self.formatter stringFromDate:move.updatedAt];
    NSString *now = [self.formatter stringFromDate:[NSDate date]];
    XCTAssert([updatedAt isEqualToString:now]);
}

@end
