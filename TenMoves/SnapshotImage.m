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

@dynamic path;
@dynamic snapshot;

+ (instancetype)newManagedObject {
    SnapshotImage *image = (SnapshotImage *) [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                                    inManagedObjectContext:[Repository managedObjectContext]];
    
    return image;
}

+ (NSString *)directory {
    NSString *imagesPath = [[self documentsDirectory] stringByAppendingPathComponent:@"/snapshot-images"];
    return imagesPath;
}

+ (void)createDirectoryUnlessItsThere:(NSError **)error {
    NSFileManager *manager = [NSFileManager defaultManager];
    
    if (![manager fileExistsAtPath:[self directory]]) {
        [manager createDirectoryAtPath:[self directory] withIntermediateDirectories:NO attributes:nil error:error];
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
    NSURL *imageDestinationUrl = [NSURL fileURLWithPath:[[SnapshotImage directory] stringByAppendingString:filename]];
    
    NSError *error;
    [imageData writeToURL:imageDestinationUrl options:NSDataWritingAtomic error:&error];
    
    if (error) {
        failureBlock(error);
    } else {
        instance.url = [imageDestinationUrl URLWithoutRootToDocumentsDirectory];
        successBlock(instance);
    }
}

- (void)setUrl:(NSURL *)url {
    self.path = url.absoluteString;
}

- (NSURL *)url {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSString *documentsPath = [appDelegate applicationDocumentsDirectory].absoluteString;
    NSString *pathWithDocumentsDirectory = [documentsPath stringByAppendingString:self.path];
    return [NSURL URLWithString:pathWithDocumentsDirectory];
}

- (void)prepareForDeletion {
    [super prepareForDeletion];
    
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
}

- (UIImage *)image {
    return [UIImage imageWithData:[NSData dataWithContentsOfURL:[self url]]];
}

@end
