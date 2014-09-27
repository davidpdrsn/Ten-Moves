//
//  MoveTests.m
//  TenMoves
//
//  Created by David Pedersen on 27/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <KIF/KIF.h>
#import "KIFTestCaseWithCoreData.h"

@interface MoveTests : KIFTestCaseWithCoreData

@end

@implementation MoveTests

- (void)testAddingAMove {
    NSString *name = @"Move 1";
    [tester tapViewWithAccessibilityLabel:@"Add move"];
    [tester enterText:name intoViewWithAccessibilityLabel:@"Name"];
    [tester tapViewWithAccessibilityLabel:@"Save"];
    [tester waitForTappableViewWithAccessibilityLabel:name];
}

- (void)testSwipeToDeleteMove {
    NSString *name = @"Move 2";
    [tester tapViewWithAccessibilityLabel:@"Add move"];
    [tester enterText:name intoViewWithAccessibilityLabel:@"Name"];
    [tester tapViewWithAccessibilityLabel:@"Save"];
    [tester swipeViewWithAccessibilityLabel:name inDirection:KIFSwipeDirectionLeft];
    [tester tapViewWithAccessibilityLabel:@"Delete"];
    NSError *error;
    [tester tryFindingViewWithAccessibilityLabel:name error:&error];
    XCTAssert(error);
}

- (void)testDeleteBulk {
    NSString *name = @"Move 3";
    [tester tapViewWithAccessibilityLabel:@"Add move"];
    [tester enterText:name intoViewWithAccessibilityLabel:@"Name"];
    [tester tapViewWithAccessibilityLabel:@"Save"];
    [tester tapViewWithAccessibilityLabel:@"Edit"];
    [tester waitForTimeInterval:1];
    [tester tapScreenAtPoint:CGPointMake(22, 121)];
    [tester tapViewWithAccessibilityLabel:@"Delete"];
    NSError *error;
    [tester tryFindingViewWithAccessibilityLabel:name error:&error];
    XCTAssert(error);
}

- (void)testRenamingAMove {
    NSString *name = @"Move 4";
    NSString *newName = @"Move 4 edited";
    [tester tapViewWithAccessibilityLabel:@"Add move"];
    [tester enterText:name intoViewWithAccessibilityLabel:@"Name"];
    [tester tapViewWithAccessibilityLabel:@"Save"];
    [tester tapViewWithAccessibilityLabel:@"Edit"];
    [tester tapViewWithAccessibilityLabel:name];
    [tester clearTextFromViewWithAccessibilityLabel:@"Name"];
    [tester enterText:newName intoViewWithAccessibilityLabel:@"Name"];
    [tester tapViewWithAccessibilityLabel:@"Save"];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester waitForViewWithAccessibilityLabel:newName];
}

- (void)testCannotAddMoreThanTenMoves {
    for (NSUInteger i = 0; i < 10; i++)
        [self addMoveNamed:[NSString stringWithFormat:@"Move %lu", (unsigned long)i]];

    [tester tapViewWithAccessibilityLabel:@"Add move"];

    NSError *error;
    [tester tryFindingViewWithAccessibilityLabel:@"Save" error:&error];
    XCTAssert(error);
}

- (void)testTappingEditWithoutMoves {
    [tester tapViewWithAccessibilityLabel:@"Edit"];

    NSError *error;
    [tester tryFindingViewWithAccessibilityLabel:@"Done" error:&error];
    XCTAssert(error);
}

- (void)addMoveNamed:(NSString *)name {
    [tester tapViewWithAccessibilityLabel:@"Add move"];
    [tester enterText:name intoViewWithAccessibilityLabel:@"Name"];
    [tester tapViewWithAccessibilityLabel:@"Save"];
    [tester waitForTappableViewWithAccessibilityLabel:name];
}

@end
