//
//  SnapshotVideo.h
//  TenMoves
//
//  Created by David Pedersen on 27/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Snapshot;

@interface SnapshotVideo : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) Snapshot *snapshot;

+ (instancetype)newManagedObject;
+ (instancetype)newManagedObjectForSnapshot:(Snapshot *)snapshot withVideoAtUrl:(NSURL *)url;

- (NSURL *)url;

@end
