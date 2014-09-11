//
//  ModelObject.h
//  TenMoves
//
//  Created by David Pedersen on 26/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Snapshot;

@interface ManagedSnapshotAsset : NSManagedObject

+ (NSString *)documentsDirectory;
+ (NSString *)createUuidString;

@property (nonatomic, retain) NSString *path;
@property (nonatomic, retain) Snapshot *snapshot;

- (void)setUrl:(NSURL *)url;
- (NSURL *)url;

@end
