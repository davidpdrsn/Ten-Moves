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

static NSString *ENTITY_NAME = @"SnapshotImage";

@implementation SnapshotImage

@dynamic path;
@dynamic snapshot;

+ (instancetype)newManagedObject {
    SnapshotImage *image = (SnapshotImage *) [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                                    inManagedObjectContext:[Repository managedObjectContext]];
    
    return image;
}

// TODO move this method into base class
+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return documentsDirectory;
}

+ (NSString *)directory {
    NSString *imagesPath = [[self documentsDirectory] stringByAppendingPathComponent:@"/snapshot-images"];
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

+ (instancetype)newManagedObjectForSnapshot:(Snapshot *)snapshot withImage:(UIImage *)image {
    [self createDirectoryUnlessItsThere];
    
    SnapshotImage *instance = [self newManagedObject];
    
    NSData *imageData = UIImagePNGRepresentation(image);
    
    NSString *filename = [NSString stringWithFormat:@"/%@.png", snapshot.uuid];
    NSURL *imageDestinationUrl = [NSURL fileURLWithPath:[[SnapshotImage directory] stringByAppendingString:filename]];
    
    [imageData writeToURL:imageDestinationUrl options:NSDataWritingAtomic error:nil];
    
    instance.path = imageDestinationUrl.absoluteString;
    instance.snapshot = snapshot;
    return instance;
}

- (NSURL *)url {
    return [NSURL URLWithString:self.path];
}

- (void)prepareForDeletion {
    [super prepareForDeletion];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
}

- (UIImage *)image {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[self url]]];
}

@end
