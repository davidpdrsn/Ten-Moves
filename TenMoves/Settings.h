//
//  Settings.h
//  TenMoves
//
//  Created by David Pedersen on 27/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Settings : NSObject

@property (assign, nonatomic) BOOL shareMovesWithAPI;

+ (instancetype)sharedInstance;

@end
