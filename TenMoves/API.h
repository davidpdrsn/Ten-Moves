//
//  API.h
//  TenMoves
//
//  Created by David Pedersen on 24/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface API : NSObject

+ (instancetype)sharedInstance;

- (void)getMoves:(void (^)(id moves, NSError *error))completionBlock;
- (void)addMove:(NSString *)name completion:(void (^)(NSError *error))completionBlock;

@end
