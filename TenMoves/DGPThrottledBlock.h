//
//  DGPThrottledBlock.h
//  TenMoves
//
//  Created by David Pedersen on 28/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DGPThrottledBlock : NSObject

- (instancetype)initWithBlock:(void (^)())block throttleDay:(NSTimeInterval)delay;

- (void)start;

@end
