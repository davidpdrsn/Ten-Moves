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
#import "AppDelegate.h"

static NSString *ENTITY_NAME = @"SnapshotVideo";

@implementation SnapshotVideo

@dynamic path;
@dynamic snapshot;

+ (instancetype)newManagedObject {
    SnapshotVideo *video = (SnapshotVideo *) [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                                    inManagedObjectContext:[Repository managedObjectContext]];
    
    return video;
}

+ (NSString *)directory {
    NSString *imagesPath = [[self documentsDirectory] stringByAppendingPathComponent:@"/snapshot-videos"];
    return imagesPath;
}

+ (void)createDirectoryUnlessItsThere:(NSError **)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:[self directory]]) {
        [manager createDirectoryAtPath:[self directory] withIntermediateDirectories:NO attributes:nil error:error];
    }
}

+ (void)newManagedObjectWithVideoAtUrl:(NSURL *)url success:(void (^)(SnapshotVideo *video))successBlock failure:(void (^)(NSError *error))failureBlock {
    NSError *createDirectoryError;
    [self createDirectoryUnlessItsThere:&createDirectoryError];
    if (createDirectoryError) {
        failureBlock(createDirectoryError);
        return;
    }
    
    SnapshotVideo *instance = [self newManagedObject];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *filename = [NSString stringWithFormat:@"/%@.%@", [self createUuidString], url.pathExtension];
    NSURL *videoDestinationUrl = [NSURL fileURLWithPath:[[self directory] stringByAppendingString:filename]];
    
    NSError *error;
    [manager copyItemAtURL:url toURL:videoDestinationUrl error:&error];
    
    if (error) {
        failureBlock(error);
    } else {
        instance.path = videoDestinationUrl.absoluteString;
        successBlock(instance);
    }
}

- (NSURL *)url {
    return [NSURL URLWithString:self.path];
}

- (void)prepareForDeletion {
    [super prepareForDeletion];
    
    [[NSFileManager defaultManager] removeItemAtURL:self.url error:nil];
}

@end
