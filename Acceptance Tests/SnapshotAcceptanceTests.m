//
//  SnapshotAcceptanceTests.m
//  TenMoves
//
//  Created by David Pedersen on 27/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <KIF/KIF.h>
#import "KIFTestCaseWithCoreData.h"
#import "Snapshot.h"

@interface SnapshotAcceptanceTests : KIFTestCaseWithCoreData {
    NSString *moveName;
}

@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation SnapshotAcceptanceTests

- (void)setUp {
    [super setUp];

    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateStyle = NSDateFormatterMediumStyle;

    moveName = @"Move";
    [tester tapViewWithAccessibilityLabel:@"Add move"];
    [tester enterText:moveName intoViewWithAccessibilityLabel:@"Name"];
    [tester tapViewWithAccessibilityLabel:@"Save"];
}

- (void)tearDown {
    [super tearDown];
    [tester tapViewWithAccessibilityLabel:@"Moves"];
}

- (void)testCannotRateBaselineSnapshot {
    [tester tapViewWithAccessibilityLabel:moveName];
    [tester tapViewWithAccessibilityLabel:@"Add snapshot"];

    NSError *error;
    [tester tryFindingViewWithAccessibilityLabel:@"Better" error:&error];
    XCTAssert(error != nil);

    [tester tapViewWithAccessibilityLabel:@"Cancel"];
}

- (void)testAddingBaselineSnapshot {
    [self addBaselineSnapshotAndReturnToMovesTable];
    [tester tapViewWithAccessibilityLabel:moveName];

    [tester waitForTappableViewWithAccessibilityLabel:[self.formatter stringFromDate:[NSDate date]]];
}

- (void)testAddingSnapshotsOfDifferentTypes {
    [self addBaselineSnapshotAndReturnToMovesTable];

    [tester tapViewWithAccessibilityLabel:moveName];
    [self addSnapshotWithTypeAndReturnToMovesTable:SnapshotProgressImproved];

    [tester tapViewWithAccessibilityLabel:moveName];
    [self addSnapshotWithTypeAndReturnToMovesTable:SnapshotProgressSame];

    [tester tapViewWithAccessibilityLabel:moveName];
    [self addSnapshotWithTypeAndReturnToMovesTable:SnapshotProgressRegressed];

    [tester tapViewWithAccessibilityLabel:moveName];
    [tester waitForViewWithAccessibilityLabel:[Snapshot textForProgressType:SnapshotProgressImproved]];
    [tester waitForViewWithAccessibilityLabel:[Snapshot textForProgressType:SnapshotProgressSame]];
    [tester waitForViewWithAccessibilityLabel:[Snapshot textForProgressType:SnapshotProgressRegressed]];
}

- (void)testViewingVideoOfSnapshot {
    [self addBaselineSnapshotAndReturnToMovesTable];
    [tester tapViewWithAccessibilityLabel:moveName];
    [tester waitForTimeInterval:2];

    NSString *dateString = [self.formatter stringFromDate:[NSDate date]];
    NSString *label = [NSString stringWithFormat:@"Play video from %@", dateString];
    [tester tapViewWithAccessibilityLabel:label];

    [tester tapViewWithAccessibilityLabel:@"Done"];
}

- (void)testDeleteSnapshot {
    [self addBaselineSnapshotAndReturnToMovesTable];
    [tester tapViewWithAccessibilityLabel:moveName];
    
    NSString *label = [self.formatter stringFromDate:[NSDate date]];
    [tester swipeViewWithAccessibilityLabel:label inDirection:KIFSwipeDirectionLeft];
    [tester tapViewWithAccessibilityLabel:@"Delete"];
    NSError *error;
    [tester tryFindingViewWithAccessibilityLabel:label error:&error];
    XCTAssert(error);
}

- (void)testCannotSeePreviousSnapshotWhenAddingBaseline {
    [tester tapViewWithAccessibilityLabel:moveName];
    [tester tapViewWithAccessibilityLabel:@"Add snapshot"];

    NSString *dateString = [self.formatter stringFromDate:[NSDate date]];
    NSString *label = [NSString stringWithFormat:@"Play video from %@", dateString];
    NSError *error;
    [tester tryFindingViewWithAccessibilityLabel:label error:&error];
    XCTAssert(error);

    [tester tapViewWithAccessibilityLabel:@"Cancel"];
}

- (void)testCanSeePreviousSnapshotWhenNotBaseline {
    [self addBaselineSnapshotAndReturnToMovesTable];
    [tester tapViewWithAccessibilityLabel:moveName];

    [tester tapViewWithAccessibilityLabel:@"Add snapshot"];

    NSString *dateString = [self.formatter stringFromDate:[NSDate date]];
    NSString *label = [NSString stringWithFormat:@"Play video from %@", dateString];
    [tester tapViewWithAccessibilityLabel:label];
    [tester tapViewWithAccessibilityLabel:@"Done"];

    [tester tapViewWithAccessibilityLabel:@"Cancel"];
}

- (void)testViewingASnapshot {
    [self createBaselineSnapshotAndNavigateToIt];

    [tester waitForViewWithAccessibilityLabel:moveName];
    [tester waitForViewWithAccessibilityLabel:[Snapshot textForProgressType:SnapshotProgressBaseline]];
    [tester waitForViewWithAccessibilityLabel:@"Edit"];
    [tester waitForViewWithAccessibilityLabel:@"No notes"];

    [tester tapViewWithAccessibilityLabel:@"Move"];
}

- (void)testPlayVideoFromShowView {
    [self createBaselineSnapshotAndNavigateToIt];
    [tester waitForTimeInterval:1];
    [tester tapScreenAtPoint:CGPointMake(50*2, 100*2)];
    [tester tapViewWithAccessibilityLabel:@"Done"];
    [tester tapViewWithAccessibilityLabel:@"Move"];
}

// TODO: Test adding snapshot without video

- (void)testEditNotes {
    [self createBaselineSnapshotAndNavigateToIt];

    [tester tapViewWithAccessibilityLabel:@"Edit"];
    [tester enterText:@"Notes are here" intoViewWithAccessibilityLabel:@"notes"];
    [tester tapViewWithAccessibilityLabel:@"Save"];

    [tester waitForViewWithAccessibilityLabel:@"Notes are here"];

    [tester tapViewWithAccessibilityLabel:@"Move"];
}

- (void)testEditType {
    [self addBaselineSnapshotAndReturnToMovesTable];
    [self addSnapshotWithTypeAndReturnToMovesTable:SnapshotProgressSame];
    [tester tapViewWithAccessibilityLabel:moveName];

    NSString *label = [self.formatter stringFromDate:[NSDate date]];
    [tester tapViewWithAccessibilityLabel:label];

    NSString *text = [Snapshot textForProgressType:SnapshotProgressRegressed];

    [tester tapViewWithAccessibilityLabel:@"Edit"];
    [tester tapViewWithAccessibilityLabel:text];
    [tester tapViewWithAccessibilityLabel:@"Save"];

    [tester waitForViewWithAccessibilityLabel:text];

    [tester tapViewWithAccessibilityLabel:@"Move"];
}

- (void)createBaselineSnapshotAndNavigateToIt {
    [self addBaselineSnapshotAndReturnToMovesTable];
    [tester tapViewWithAccessibilityLabel:moveName];
    
    NSString *label = [self.formatter stringFromDate:[NSDate date]];
    [tester tapViewWithAccessibilityLabel:label];
}

- (void)addBaselineSnapshotAndReturnToMovesTable {
    [tester tapViewWithAccessibilityLabel:moveName];
    [tester tapViewWithAccessibilityLabel:@"Add snapshot"];
    [tester tapViewWithAccessibilityLabel:@"Pick video"];
    [tester tapViewWithAccessibilityLabel:@"Choose Existing"];
    [tester tapViewWithAccessibilityLabel:@"All Photos"];
    [tester waitForTimeInterval:1];
    [tester tapScreenAtPoint:CGPointMake(45*2, 100*2)];
    [tester tapViewWithAccessibilityLabel:@"Choose"];
    [tester tapViewWithAccessibilityLabel:@"Save"];
    [tester tapViewWithAccessibilityLabel:@"Moves"];
}

- (void)addSnapshotWithTypeAndReturnToMovesTable:(SnapshotProgress)type {
    [tester tapViewWithAccessibilityLabel:moveName];
    [tester tapViewWithAccessibilityLabel:@"Add snapshot"];
    [tester tapViewWithAccessibilityLabel:@"Pick video"];
    [tester tapViewWithAccessibilityLabel:@"Choose Existing"];
    [tester tapViewWithAccessibilityLabel:@"All Photos"];
    [tester waitForTimeInterval:1];
    [tester tapScreenAtPoint:CGPointMake(45*2, 100*2)];
    [tester tapViewWithAccessibilityLabel:@"Choose"];
    [tester tapViewWithAccessibilityLabel:[Snapshot textForProgressType:type]];
    [tester tapViewWithAccessibilityLabel:@"Save"];
    [tester tapViewWithAccessibilityLabel:@"Moves"];
}

@end
