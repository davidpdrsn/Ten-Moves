//
//  SnapshotVideo.h
//  TenMoves
//
//  Created by David Pedersen on 27/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ModelObject.h"

@class Snapshot;

@interface SnapshotVideo : ModelObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) Snapshot *snapshot;

+ (instancetype)newManagedObject;
+ (void)newManagedObjectWithVideoAtUrl:(NSURL *)url success:(void (^)(SnapshotVideo *video))successBlock failure:(void (^)(NSError *error))failureBlock;

- (NSURL *)url;

@end
