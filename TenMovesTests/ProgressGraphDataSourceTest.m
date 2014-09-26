//
//  ProgressGraphDataSourceTest.m
//  TenMoves
//
//  Created by David Pedersen on 26/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "ProgressGraphDataSource.h"
#import "Snapshot.h"
#import "TestCaseWithCoreData.h"
#import "Move.h"

ProgressGraphDataSource* newDataSource(NSSet *snapshots) {
    return [[ProgressGraphDataSource alloc] initWithSnapshots:snapshots];
}

Snapshot* newSnapshotOnMove(Move *move) {
    Snapshot *one = [Snapshot newManagedObject];
    [move addSnapshotsObject:one];
    return one;
}

Snapshot* newSnapshotOnMoveWithType(Move *move, SnapshotProgress type) {
    Snapshot *one = [Snapshot newManagedObject];
    [one setProgressTypeRaw:type];
    [move addSnapshotsObject:one];
    return one;
}

@interface ProgressGraphDataSourceTest : TestCaseWithCoreData {
    Move *move;
}

@end

@implementation ProgressGraphDataSourceTest

- (void)setUp {
    [super setUp];
    move = [Move newManagedObject];
}

- (void)testNumberOfSnapshots {
    newSnapshotOnMove(move);
    newSnapshotOnMove(move);
    newSnapshotOnMove(move);

    ProgressGraphDataSource *dataSource = newDataSource(move.snapshots);

    XCTAssertEqual([dataSource numberOfSnapshots], 3);
}

- (void)testNumberOfSnapshotsWhenThereAreNone {
    ProgressGraphDataSource *dataSource = newDataSource(move.snapshots);

    XCTAssertEqual([dataSource numberOfSnapshots], 0);
}

- (void)testDataPointsWhenThereAreNoSnapshots {
    ProgressGraphDataSource *dataSource = newDataSource(move.snapshots);

    XCTAssertEqual([dataSource dataPoints].count, 0);
}

- (void)testDataPointsWhenTheresOnlyBaseline {
    newSnapshotOnMoveWithType(move, SnapshotProgressBaseline);
    ProgressGraphDataSource *dataSource = newDataSource(move.snapshots);
    XCTAssertEqual([dataSource dataPoints].count, 1);
    XCTAssert([(NSNumber *)[dataSource dataPoints][0] isEqualToNumber:@0]);
}

- (void)testDataPointsWhenTheresMoreSnapshots {
    newSnapshotOnMoveWithType(move, SnapshotProgressBaseline);
    newSnapshotOnMoveWithType(move, SnapshotProgressImproved);
    newSnapshotOnMoveWithType(move, SnapshotProgressImproved);
    newSnapshotOnMoveWithType(move, SnapshotProgressSame);
    newSnapshotOnMoveWithType(move, SnapshotProgressRegressed);

    ProgressGraphDataSource *dataSource = newDataSource(move.snapshots);

    XCTAssert([(NSNumber *)[dataSource dataPoints][0] isEqualToNumber:@0]);
    XCTAssert([(NSNumber *)[dataSource dataPoints][1] isEqualToNumber:@1]);
    XCTAssert([(NSNumber *)[dataSource dataPoints][2] isEqualToNumber:@2]);
    XCTAssert([(NSNumber *)[dataSource dataPoints][3] isEqualToNumber:@2]);
    XCTAssert([(NSNumber *)[dataSource dataPoints][4] isEqualToNumber:@1]);
}

@end
