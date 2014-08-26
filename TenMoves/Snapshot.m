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
@import AssetsLibrary;
@import AVFoundation;
#import "ALAssetsLibrary+HelperMethods.h"
#import "SnapshotImage.h"
#import "SnapshotVideo.h"
#import "VideoEditor.h"

static NSString *ENTITY_NAME = @"Snapshot";

@implementation Snapshot

@dynamic createdAt;
@dynamic progress;
@dynamic updatedAt;
@dynamic move;
@dynamic image;
@dynamic video;
@dynamic notes;

+ (instancetype)newManagedObject {
    Snapshot *snapshot = (Snapshot *) [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                                    inManagedObjectContext:[Repository managedObjectContext]];
    
    return snapshot;
}

+ (NSFetchRequest *)fetchRequestForSnapshotsBelongingToMove:(Move *)move {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[Repository managedObjectContext]];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"move = %@", move];
    [fetchRequest setPredicate:predicate];
    
    return fetchRequest;
}

+ (NSSet *)keyPathsForValuesAffectingItemTypeRaw {
    return [NSSet setWithObject:@"progress"];
}

+ (NSDictionary *)propertiesForProgressType:(SnapshotProgress)type {
    switch (type) {
        case SnapshotProgressImproved:
            return @{
              @"color": [UIColor colorWithRed:0.225 green:0.848 blue:0.423 alpha:1.000],
              @"text": @"Better"
              };
            break;
        case SnapshotProgressSame:
            return @{
              @"color": [UIColor colorWithRed:1.000 green:0.780 blue:0.153 alpha:1.000],
              @"text": @"Same"
              };
            break;
        case SnapshotProgressRegressed:
            return @{
              @"color": [UIColor colorWithRed:0.945 green:0.233 blue:0.221 alpha:1.000],
              @"text": @"Worse"
              };
            break;
        case SnapshotProgressBaseline:
            return @{
              @"color": [UIColor colorWithRed:0.707 green:0.775 blue:0.785 alpha:1.000],
              @"text": @"Baseline"
              };
            break;
        default:
            // can't be reached
            break;
    }
}

+ (UIColor *)colorForProgressType:(SnapshotProgress)type {
    return [self propertiesForProgressType:type][@"color"];
}

+ (NSString *)textForProgressType:(SnapshotProgress)type {
    return [self propertiesForProgressType:type][@"text"];
}

- (NSString *)textForProgressType {
    return [Snapshot textForProgressType:[self progressTypeRaw]];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    NSDate *date = [NSDate date];
    self.updatedAt = date;
    self.createdAt = date;
    
    [self setProgressTypeRaw:SnapshotProgressBaseline];
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

- (void)saveVideoAtFileUrl:(NSURL *)mediaUrl
            completionBlock:(void (^)())completionBlock
               failureBlock:(void (^)(NSError *error))failureBlock {
    
    [SnapshotVideo newManagedObjectWithVideoAtUrl:mediaUrl success:^(SnapshotVideo *video) {
        VideoEditor *editor = [[VideoEditor alloc] init];
        UIImage *image = [editor thumbnailForVideoAtUrl:mediaUrl];
        
        [SnapshotImage newManagedObjectWithImage:image success:^(SnapshotImage *image) {
            self.video = video;
            self.image = image;
            completionBlock();
        } failure:^(NSError *error) {
            failureBlock(error);
        }];
    } failure:^(NSError *error) {
        failureBlock(error);
    }];
}

- (BOOL)hasNotes {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    BOOL noteIsBlank = [self.notes stringByTrimmingCharactersInSet: set].length == 0;
    
    return self.notes.length && !noteIsBlank;
}

- (BOOL)isBaseline {
    NSSet *allSnapshots = self.move.snapshots;
    
    if (allSnapshots.count < 2) {
        return YES;
    } else {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
        NSArray *sortedSnapshots = [allSnapshots sortedArrayUsingDescriptors:@[sortDescriptor]];
        Snapshot *first = [sortedSnapshots firstObject];
        return [first.createdAt isEqualToDate:self.createdAt];
    }
}

@end