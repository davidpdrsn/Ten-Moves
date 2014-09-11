//
//  SnapshotImage.h
//  TenMoves
//
//  Created by David Pedersen on 27/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ManagedSnapshotAsset.h"

@class Snapshot;

@interface SnapshotImage : ManagedSnapshotAsset

+ (instancetype)newManagedObject;
+ (void)newManagedObjectWithImage:(UIImage *)image success:(void (^)(SnapshotImage *image))successBlock failure:(void (^)(NSError *error))failureBlock;

- (UIImage *)image;

@end
