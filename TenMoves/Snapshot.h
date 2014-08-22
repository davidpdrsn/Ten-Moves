//
//  Snapshot.h
//  TenMoves
//
//  Created by David Pedersen on 17/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ModelObject.h"

// TODO: rename to SnapshotProgressType
typedef enum {
    SnapshotProgressImproved = 0,
    SnapshotProgressSame = 1,
    SnapshotProgressRegressed = 2,
    SnapshotProgressBaseline = 3
} SnapshotProgress;

@class Move, SnapshotImage, SnapshotVideo;

@interface Snapshot : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSNumber * progress;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) Move *move;
@property (nonatomic, retain) SnapshotImage *image;
@property (nonatomic, retain) SnapshotVideo *video;
@property (nonatomic, retain) NSString *notes;

+ (instancetype)newManagedObject;
+ (NSFetchRequest *)fetchRequestForSnapshotsBelongingToMove:(Move *)move;

+ (UIColor *)colorForProgressType:(SnapshotProgress)type;
+ (NSString *)textForProgressType:(SnapshotProgress)type;

- (SnapshotProgress)progressTypeRaw;
- (void)setProgressTypeRaw:(SnapshotProgress)type;
- (UIColor *)colorForProgressType;
- (NSString *)textForProgressType;

- (void)saveVideoAtFileUrl:(NSURL *)mediaUrl
            completionBlock:(void (^)())completionBlock
               failureBlock:(void (^)(NSError *error))failureBlock;

- (BOOL)hasNotes;

@end
