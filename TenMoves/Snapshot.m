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
#import "AppDelegate.h"
#import "NSString+RegExpHelpers.h"
#import "NSURL+ReformattingHelpers.h"

static NSString *ENTITY_NAME = @"Snapshot";

@interface Snapshot () {
    UIImage *_cachedImage;
    NSURL *_cachedVideoUrl;
}

@end

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

- (void)addObservers {
    [self addObserver:self forKeyPath:@"video" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"move" options:0 context:NULL];
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    NSDate *date = [NSDate date];
    self.updatedAt = date;
    self.createdAt = date;
    
    [self setProgressTypeRaw:SnapshotProgressImproved];
    
    [self addObservers];
}

- (void)checkIfSnapshotHasBecomeBasline {
    if ([self isBaselineRawCheck]) {
        [self setProgressTypeRaw:SnapshotProgressBaseline];
    }
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self addObservers];
    [self checkIfSnapshotHasBecomeBasline];
    [self correctUrls];
}

- (void)correctUrls {
    NSString *imagePath = self.image.path;
    NSString *videoPath = self.video.path;
    BOOL wrongImagePath = [imagePath rangeOfString:@"file:///"].location != NSNotFound;
    BOOL wrongVideoPath = [videoPath rangeOfString:@"file:///"].location != NSNotFound;
    
    if (wrongImagePath) {
        self.image.url = [self.image.url URLWithRootToDocumentsDirectoryRemoved];
    }
    
    if (wrongVideoPath) {
        self.video.url = [self.video.url URLWithRootToDocumentsDirectoryRemoved];
    }
    
    if (wrongVideoPath || wrongImagePath) {
        [Repository saveWithCompletionHandler:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"video"]) {
        [self invalidateCaches];
    } else if ([keyPath isEqualToString:@"move"]) {
        [self checkIfSnapshotHasBecomeBasline];
    }
}

- (void)prepareCache {
    [self cachedImage];
    [self cachedVideo];
}

- (void)invalidateCaches {
    _cachedVideoUrl = nil;
    _cachedImage = nil;
}

- (UIImage *)cachedImage {
    if (!_cachedImage) {
        _cachedImage = self.image.image;
    }
    return _cachedImage;
}

- (NSURL *)cachedVideo {
    if (!_cachedVideoUrl) {
        _cachedVideoUrl = [self.video url];
    }
    return _cachedVideoUrl;
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
        } failure:failureBlock];
    } failure:failureBlock];
}

- (BOOL)hasNotes {
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    BOOL noteIsBlank = [self.notes stringByTrimmingCharactersInSet: set].length == 0;
    
    return self.notes.length && !noteIsBlank;
}

- (BOOL)isBaselineRawCheck {
    NSSet *allSnapshots = self.move.snapshots;
    
    if (allSnapshots.count < 2) {
        return YES;
    } else {
        Snapshot *first = [[self sortedRelatedSnapshots] firstObject];
        return [first.createdAt isEqualToDate:self.createdAt];
    }
}

- (NSArray *)sortedRelatedSnapshots {
    NSSet *allSnapshots = self.move.snapshots;
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    NSArray *sortedSnapshots = [allSnapshots sortedArrayUsingDescriptors:@[sortDescriptor]];
    return sortedSnapshots;
}

- (BOOL)isBaseline {
    return [self progressTypeRaw] == SnapshotProgressBaseline;
}

- (void)prepareForDeletion {
    if ([self isBaseline]) {
        NSArray *sortedSnapshots = [self sortedRelatedSnapshots];
        
        if (1 < sortedSnapshots.count) {
            Snapshot *nextSnapshot = sortedSnapshots[1];
            [nextSnapshot setProgressTypeRaw:SnapshotProgressBaseline];
        }
    }
}

@end