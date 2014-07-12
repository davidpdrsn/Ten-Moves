//
//  Move.h
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Snapshot;

@interface Move : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *snapshots;

+ (instancetype)newManagedObject;

+ (NSFetchRequest *)fetchRequest;

@end

@interface Move (CoreDataGeneratedAccessors)

- (void)addSnapshotsObject:(Snapshot *)value;
- (void)removeSnapshotsObject:(Snapshot *)value;
- (void)addSnapshots:(NSSet *)values;
- (void)removeSnapshots:(NSSet *)values;

@end
