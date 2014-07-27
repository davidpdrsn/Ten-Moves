//
//  ModelObject.m
//  TenMoves
//
//  Created by David Pedersen on 26/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ModelObject.h"
#import "AppDelegate.h"

@implementation ModelObject

+ (NSString *)documentsDirectory {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    return documentsDirectory;
}

+ (NSString *)createUuidString {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

@end
