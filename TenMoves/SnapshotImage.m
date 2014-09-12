//
//  SnapshotImage.m
//  TenMoves
//
//  Created by David Pedersen on 27/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "SnapshotImage.h"
#import "Snapshot.h"
#import "Repository.h"
#import "AppDelegate.h"
#import "NSURL+ReformattingHelpers.h"

static NSString *ENTITY_NAME = @"SnapshotImage";

@implementation SnapshotImage

+ (instancetype)newManagedObject {
    SnapshotImage *image = (SnapshotImage *) [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                                    inManagedObjectContext:[Repository managedObjectContext]];
    
    return image;
}

+ (NSURL *)directory {
    return [[self documentsDirectory] URLByAppendingPathComponent:@"snapshot-images"];
}

+ (void)createDirectoryUnlessItsThere:(NSError **)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:[self directory].path]) {
        [manager createDirectoryAtURL:[self directory] withIntermediateDirectories:NO attributes:nil error:error];
    }
}

+ (void)newManagedObjectWithImage:(UIImage *)image success:(void (^)(SnapshotImage *image))successBlock failure:(void (^)(NSError *error))failureBlock {
    NSError *createDirectoryError;
    [self createDirectoryUnlessItsThere:&createDirectoryError];
    if (createDirectoryError) {
        failureBlock(createDirectoryError);
        return;
    }
    
    SnapshotImage *instance = [self newManagedObject];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *filename = [NSString stringWithFormat:@"/%@.png", [self createUuidString]];
    NSURL *imageDestinationUrl = [[SnapshotImage directory] URLByAppendingPathComponent:filename];
    
    NSError *error;
    [imageData writeToURL:imageDestinationUrl options:NSDataWritingAtomic error:&error];
    
    if (error) {
        failureBlock(error);
    } else {
        instance.url = [imageDestinationUrl URLWithoutRootToDocumentsDirectory];
        successBlock(instance);
    }
}

- (UIImage *)image {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[self url]]];
}

@end
