//
//  Snapshot.h
//  TenMoves
//
//  Created by David Pedersen on 17/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef enum {
    SnapshotProgressImproved = 0,
    SnapshotProgressSame = 1,
    SnapshotProgressRegressed = 2,
    SnapshotProgressBaseline = 3
} SnapshotProgress;

@class Move;

@interface Snapshot : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * videoPath;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) Move *move;

+ (instancetype)newManagedObject;
+ (NSFetchRequest *)fetchRequestForMove:(Move *)move;
+ (UIColor *)colorForProgressType:(SnapshotProgress)type;

- (NSURL *)videoUrl;
- (SnapshotProgress)progressTypeRaw;
- (void)setProgressTypeRaw:(SnapshotProgress)type;
- (UIColor *)colorForProgressType;

@end
