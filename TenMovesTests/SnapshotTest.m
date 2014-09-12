//
//  SnapshotTest.m
//  TenMoves
//
//  Created by David Pedersen on 12/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Snapshot.h"
#import "Move.h"
#import "TestCaseWithCoreData.h"

@interface SnapshotTest : TestCaseWithCoreData

@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation SnapshotTest

- (void)setUp {
    [super setUp];
    self.formatter = [[NSDateFormatter alloc] init];
    self.formatter.dateStyle = NSDateFormatterLongStyle;
}

- (void)testHasNoNotesWhenJustCreated {
    Snapshot *snapshot = [Snapshot newManagedObject];
    XCTAssert(![snapshot hasNotes]);
}

- (void)testHasNotesWhenNotesAreEmpty {
    Snapshot *snapshot = [Snapshot newManagedObject];
    snapshot.notes = @"";
    XCTAssert(![snapshot hasNotes]);
}

- (void)testHasNotesWhenNotesAreBlank {
    Snapshot *snapshot = [Snapshot newManagedObject];
    snapshot.notes = @"         ";
    XCTAssert(![snapshot hasNotes]);
}

- (void)testNotesWhenThereAreNotes {
    Snapshot *snapshot = [Snapshot newManagedObject];
    snapshot.notes = @"      note!   ";
    XCTAssert([snapshot hasNotes]);
}

- (void)testIsBaselineWhenOnlySnapshot {
    Move *move = [Move newManagedObject];
    Snapshot *baselineSnapshot = [Snapshot newManagedObject];
    baselineSnapshot.move = move;
    XCTAssert([baselineSnapshot isBaseline]);
}

- (void)testIsBaselineWhenMoreSnapshots {
    Move *move = [Move newManagedObject];
    Snapshot *baselineSnapshot = [Snapshot newManagedObject];
    baselineSnapshot.move = move;

    Snapshot *anotherSnapshot = [Snapshot newManagedObject];
    anotherSnapshot.move = move;

    XCTAssert([baselineSnapshot isBaseline]);
}

- (void)testIsNotBaseline {
    Move *move = [Move newManagedObject];
    Snapshot *baselineSnapshot = [Snapshot newManagedObject];
    baselineSnapshot.move = move;

    Snapshot *anotherSnapshot = [Snapshot newManagedObject];
    anotherSnapshot.move = move;

    XCTAssert(![anotherSnapshot isBaseline]);
}

- (void)testCreatedAt {
    Snapshot *snapshot = [Snapshot newManagedObject];

    NSString *createdAt = [self.formatter stringFromDate:snapshot.createdAt];
    NSString *now = [self.formatter stringFromDate:[NSDate date]];

    XCTAssert([createdAt isEqualToString:now]);
}

- (void)testUpdatedAtWhenBrandNew {
    Snapshot *snapshot = [Snapshot newManagedObject];

    NSString *updatedAt = [self.formatter stringFromDate:snapshot.updatedAt];
    NSString *now = [self.formatter stringFromDate:[NSDate date]];
    XCTAssert([updatedAt isEqualToString:now]);
}

- (void)testUpdatedAtChangingProperties {
    Snapshot *snapshot = [Snapshot newManagedObject];
    NSDate *inThePast = [NSDate dateWithTimeIntervalSince1970:0];
    snapshot.updatedAt = inThePast;

    snapshot.notes = @"here are some new notes";

    NSString *updatedAt = [self.formatter stringFromDate:snapshot.updatedAt];
    NSString *now = [self.formatter stringFromDate:[NSDate date]];
    XCTAssert([updatedAt isEqualToString:now]);
}

@end
