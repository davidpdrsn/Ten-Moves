//
//  SnapshotImage.h
//  TenMoves
//
//  Created by David Pedersen on 27/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Snapshot;

@interface SnapshotImage : NSManagedObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) Snapshot *snapshot;

+ (instancetype)newManagedObject;
+ (instancetype)newManagedObjectForSnapshot:(Snapshot *)snapshot withImage:(UIImage *)image;

- (NSURL *)url;
- (UIImage *)image;

@end
