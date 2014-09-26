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

@end

@implementation ProgressGraphDataSource

- (instancetype)initWithSnapshots:(NSSet *)snapshots {
    self = [super init];
    if (self) {
        _snapshots = snapshots;
    }
    return self;
}

- (NSInteger)numberOfSnapshots {
    return self.snapshots.count;
}

- (NSArray *)dataPoints {
    NSMutableArray *acc = [@[] mutableCopy];

    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    NSArray *all = [[self.snapshots allObjects] sortedArrayUsingDescriptors:@[sort]];

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

@end
