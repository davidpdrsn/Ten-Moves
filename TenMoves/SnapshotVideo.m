//
//  SnapshotVideo.m
//  TenMoves
//
//  Created by David Pedersen on 27/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "SnapshotVideo.h"
#import "Snapshot.h"
#import "Repository.h"

static NSString *ENTITY_NAME = @"SnapshotVideo";

@implementation SnapshotVideo

@dynamic path;
@dynamic snapshot;

+ (instancetype)newManagedObject {
    SnapshotVideo *video = (SnapshotVideo *) [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                                    inManagedObjectContext:[Repository managedObjectContext]];
    
    return video;
}

// TODO move this method into base class
+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return documentsDirectory;
}

+ (NSString *)directory {
    NSString *imagesPath = [[self documentsDirectory] stringByAppendingPathComponent:@"/snapshot-videos"];
    return imagesPath;
}

+ (void)createDirectoryUnlessItsThere {
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:[self directory]]) {
        [manager createDirectoryAtPath:[self directory] withIntermediateDirectories:NO
                            attributes:nil
                                 error:nil];
    }
}

+ (instancetype)newManagedObjectForSnapshot:(Snapshot *)snapshot withVideoAtUrl:(NSURL *)url {
    [self createDirectoryUnlessItsThere];
    SnapshotVideo *instance = [self newManagedObject];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *filename = [NSString stringWithFormat:@"/%@.%@", [self createUuidString], url.pathExtension];
    NSURL *videoDestinationUrl = [NSURL fileURLWithPath:[[self directory] stringByAppendingString:filename]];
    
    instance.path = videoDestinationUrl.absoluteString;
    
    [manager copyItemAtURL:url toURL:videoDestinationUrl error:nil];
    
    return instance;
}

- (NSURL *)url {
    return [NSURL URLWithString:self.path];
}

- (void)prepareForDeletion {
    [[NSFileManager defaultManager] removeItemAtURL:self.url error:nil];
}

+ (NSString *)createUuidString {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

@end
