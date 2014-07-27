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
#import "ALAssetsLibrary+HelperMethods.h"

static NSString *ENTITY_NAME = @"Snapshot";

@implementation Snapshot

@dynamic createdAt;
@dynamic updatedAt;
@dynamic videoPath;
@dynamic imagePath;
@dynamic uuid;
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
    self.uuid = [self createUuidString];
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

- (void)prepareForDeletion {
    NSFileManager *manager = [[NSFileManager alloc] init];
    [manager removeItemAtURL:self.videoUrl error:nil];
    [manager removeItemAtURL:self.imageUrl error:nil];
}

- (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return documentsDirectory;
}

- (void)saveVideoAtMediaUrl:(NSURL *)mediaUrl
           withReferenceUrl:(NSURL *)referenceUrl
       completionBlock:(void (^)())completionBlock
               failureBlock:(void (^)(NSError *error))failureBlock {
    
    NSString *documentsDirectory = [self documentsDirectory];
    
    NSString *videosPath = [documentsDirectory stringByAppendingPathComponent:@"/snapshot-videos"];
    NSString *imagesPath = [documentsDirectory stringByAppendingPathComponent:@"/snapshot-images"];
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    
    NSError *createVideoDirectoryError;
    if (![manager fileExistsAtPath:videosPath]) {
        [manager createDirectoryAtPath:videosPath withIntermediateDirectories:NO attributes:nil error:&createVideoDirectoryError];
        if (createVideoDirectoryError) {
            failureBlock(createVideoDirectoryError);
            return;
        }
    }
    
    NSError *createImageDirectoryError;
    if (![manager fileExistsAtPath:imagesPath]) {
        [manager createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:&createImageDirectoryError];
        if (createImageDirectoryError) {
            failureBlock(createImageDirectoryError);
            return;
        }
    }
    
    NSString *filename = [NSString stringWithFormat:@"/%@.%@", self.uuid, mediaUrl.pathExtension];
    NSURL *videoDestinationUrl = [NSURL fileURLWithPath:[videosPath stringByAppendingString:filename]];
    
    NSError *copyVideoError;
    [manager copyItemAtURL:mediaUrl toURL:videoDestinationUrl error:&copyVideoError];
    if (copyVideoError) {
        failureBlock(copyVideoError);
        return;
    }
    
    self.videoPath = videoDestinationUrl.absoluteString;
    
    [ALAssetsLibrary assetForURL:referenceUrl resultBlock:^(ALAsset *asset) {
        UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSString *filename = [NSString stringWithFormat:@"/%@.png", self.uuid];
        NSURL *imageDestinationUrl = [NSURL fileURLWithPath:[imagesPath stringByAppendingString:filename]];
        
        self.imagePath = imageDestinationUrl.absoluteString;
        
        NSError *writeImageError;
        [imageData writeToURL:imageDestinationUrl options:NSDataWritingAtomic error:&writeImageError];
        if (writeImageError) {
            failureBlock(writeImageError);
        } else {
            completionBlock();
        }
    } failureBlock:^(NSError *error) {
        failureBlock(error);
    }];
}

- (NSString *)createUuidString {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

@end