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
#import "NSURL+ReformattingHelpers.h"
#import "NSString+RegExpHelpers.h"

static NSString *ENTITY_NAME = @"SnapshotVideo";

@implementation SnapshotVideo

+ (instancetype)newManagedObject {
    SnapshotVideo *video = (SnapshotVideo *) [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                                    inManagedObjectContext:[Repository managedObjectContext]];
    
    return video;
}

+ (NSURL *)directory {
    return [[self documentsDirectory] URLByAppendingPathComponent:@"snapshot-videos"];
}

+ (void)createDirectoryUnlessItsThere:(NSError **)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:[self directory].path]) {
        [manager createDirectoryAtURL:[self directory] withIntermediateDirectories:NO attributes:nil error:error];
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
    NSURL *videoDestinationUrl = [[self directory] URLByAppendingPathComponent:filename];
    
    NSError *error;
    [manager copyItemAtURL:url toURL:videoDestinationUrl error:&error];
    
    if (error) {
        failureBlock(error);
    } else {
        instance.url = [videoDestinationUrl URLWithoutRootToDocumentsDirectory];
        successBlock(instance);
    }
}

@end
