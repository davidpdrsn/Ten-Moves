//
//  Globals.h
//  TenMoves
//
//  Created by David Pedersen on 28/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Globals : NSObject

+ (instancetype)sharedInstance;

@property (assign, nonatomic) NSUInteger maxNumberOfMoves;

@end
