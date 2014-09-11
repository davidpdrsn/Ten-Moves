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

+ (NSString *)documentsDirectory {
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    NSString *documentsPath = [appDelegate applicationDocumentsDirectory].absoluteString;
    return documentsPath;
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
    NSString *pathWithDocumentsDirectory = [[self.class documentsDirectory] stringByAppendingString:self.path];
    return [NSURL URLWithString:pathWithDocumentsDirectory];
}

@end
