//
//  ModelObject.m
//  TenMoves
//
//  Created by David Pedersen on 26/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ManagedSnapshotAsset.h"
#import "AppDelegate.h"

@implementation ManagedSnapshotAsset

@dynamic path;
@dynamic snapshot;

+ (NSURL *)documentsDirectory {
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [searchPaths objectAtIndex:0];
    return [NSURL fileURLWithPath:documentPath];
}

+ (NSString *)createUuidString {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

- (void)prepareForDeletion {
    [super prepareForDeletion];
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
}

- (void)setUrl:(NSURL *)url {
    self.path = url.absoluteString;
}

- (NSURL *)url {
    return [[self.class documentsDirectory] URLByAppendingPathComponent:self.path];
}

@end
