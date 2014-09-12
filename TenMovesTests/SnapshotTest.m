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

@end

@implementation SnapshotTest

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

@end
