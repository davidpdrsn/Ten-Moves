//
//  Snapshot.m
//  TenMoves
//
//  Created by David Pedersen on 17/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "Snapshot.h"
#import "Move.h"
#import "Repository.h"

static NSString *ENTITY_NAME = @"Snapshot";

@implementation Snapshot

@dynamic createdAt;
@dynamic videoPath;
@dynamic move;
@dynamic progress;

+ (instancetype)newManagedObject {
    Snapshot *snapshot = (Snapshot *) [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                                    inManagedObjectContext:[Repository managedObjectContext]];
    
    return snapshot;
}

+ (NSFetchRequest *)fetchRequestForMove:(Move *)move {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[Repository managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"move = %@", move];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

+(NSSet *)keyPathsForValuesAffectingItemTypeRaw {
    return [NSSet setWithObject:@"progress"];
}

+ (UIColor *)colorForProgressType:(SnapshotProgress)type {
    switch (type) {
        case SnapshotProgressImproved:
            return [UIColor greenColor];
            break;
        case SnapshotProgressSame:
            return [UIColor yellowColor];
            break;
        case SnapshotProgressRegressed:
            return [UIColor redColor];
            break;
        default:
            // can't be reached
            break;
    }
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self setValue:[NSDate date] forKey:@"createdAt"];
}

- (NSURL *)videoUrl {
    return [NSURL URLWithString:self.videoPath];
}

- (SnapshotProgress)progressTypeRaw {
    return (SnapshotProgress)self.progress.intValue;
}

- (void)setProgressTypeRaw:(SnapshotProgress)type {
    self.progress = [NSNumber numberWithInt:type];
}

- (UIColor *)colorForProgressType {
    return [self.class colorForProgressType:self.progressTypeRaw];
}

@end