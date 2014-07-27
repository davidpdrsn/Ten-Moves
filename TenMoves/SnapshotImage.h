//
//  SnapshotImage.h
//  TenMoves
//
//  Created by David Pedersen on 27/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "ModelObject.h"

@class Snapshot;

@interface SnapshotImage : ModelObject

@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) Snapshot *snapshot;

+ (instancetype)newManagedObject;
+ (void)newManagedObjectWithImage:(UIImage *)image success:(void (^)(SnapshotImage *image))successBlock failure:(void (^)(NSError *error))failureBlock;

- (NSURL *)url;
- (UIImage *)image;

@end
