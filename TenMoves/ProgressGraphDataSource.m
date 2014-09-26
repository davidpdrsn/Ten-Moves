//
//  ProgressGraphDataSource.m
//  TenMoves
//
//  Created by David Pedersen on 26/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ProgressGraphDataSource.h"
#import "Snapshot.h"

@interface ProgressGraphDataSource ()

@property (strong, nonatomic) NSSet *snapshots;
@property (strong, nonatomic) NSDateFormatter *formatter;

@end

@implementation ProgressGraphDataSource

- (instancetype)initWithSnapshots:(NSSet *)snapshots {
    self = [super init];
    if (self) {
        _snapshots = snapshots;
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateStyle:NSDateFormatterShortStyle];
    }
    return self;
}

- (NSInteger)numberOfSnapshots {
    return self.snapshots.count;
}

- (NSArray *)sortedSnapshots {
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    NSArray *all = [[self.snapshots allObjects] sortedArrayUsingDescriptors:@[sort]];
    return all;
}

- (NSArray *)dataPoints {
    NSMutableArray *acc = [@[] mutableCopy];

    NSArray *all = [self sortedSnapshots];

    for (NSUInteger i = 0; i < all.count; i++) {
        Snapshot *snap = all[i];

        // The first snapshot is always the baseline
        if (i == 0) {
            [acc addObject:[NSNumber numberWithInteger:0]];
        } else {
            NSInteger prevValue = ((NSNumber *)acc[i-1]).integerValue;
            NSNumber *nextValue;

            switch (snap.progressTypeRaw) {
                case SnapshotProgressImproved:
                    nextValue = [NSNumber numberWithInteger:prevValue+1];
                    break;

                case SnapshotProgressRegressed:
                    nextValue = [NSNumber numberWithInteger:prevValue-1];
                    break;

                default:
                    nextValue = [NSNumber numberWithInteger:prevValue];
                    break;
            }

            [acc addObject:nextValue];
        }
    }

    return [NSArray arrayWithArray:acc];
}

#pragma mark - Line graph data source

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    return [self numberOfSnapshots];
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    NSNumber *number = [self dataPoints][index];
    return [number floatValue];
}

//- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
//    Snapshot *snap = [self sortedSnapshots][index];
//    return [self.formatter stringFromDate:snap.createdAt];
//}
//
//- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
//    return 2;
//}

@end
