//
//  ProgressGraphDataSource.h
//  TenMoves
//
//  Created by David Pedersen on 26/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BEMSimpleLineGraphView.h"

@class Snapshot;

@interface ProgressGraphDataSource : NSObject <BEMSimpleLineGraphDataSource, BEMSimpleLineGraphDelegate>

- (instancetype)initWithSnapshots:(NSSet *)snapshots;

- (NSInteger)numberOfSnapshots;
- (NSArray *)dataPoints;

@end
