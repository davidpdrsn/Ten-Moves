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
@dynamic updatedAt;
@dynamic videoPath;
@dynamic imagePath;
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

// TODO: delegate video when deleting snapshot

+ (UIColor *)colorForProgressType:(SnapshotProgress)type {
    switch (type) {
        case SnapshotProgressImproved:
            return [UIColor colorWithRed:0.225 green:0.848 blue:0.423 alpha:1.000];
            break;
        case SnapshotProgressSame:
            return [UIColor colorWithRed:1.000 green:0.780 blue:0.153 alpha:1.000];
            break;
        case SnapshotProgressRegressed:
            return [UIColor colorWithRed:0.945 green:0.233 blue:0.221 alpha:1.000];
            break;
        case SnapshotProgressBaseline:
            return [UIColor colorWithRed:0.707 green:0.775 blue:0.785 alpha:1.000];
            break;
        default:
            // can't be reached
            break;
    }
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [self setProgressTypeRaw:SnapshotProgressBaseline];
}

- (NSURL *)videoUrl {
    return [NSURL URLWithString:self.videoPath];
}

- (NSURL *)imageUrl {
    return [NSURL URLWithString:self.imagePath];
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