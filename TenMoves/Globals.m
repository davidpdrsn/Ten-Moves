//
//  Globals.m
//  TenMoves
//
//  Created by David Pedersen on 28/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "Globals.h"

@implementation Globals

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static Globals * sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

@end
