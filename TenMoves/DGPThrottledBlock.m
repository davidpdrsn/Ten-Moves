//
//  DGPThrottledBlock.m
//  TenMoves
//
//  Created by David Pedersen on 28/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "DGPThrottledBlock.h"

@interface DGPThrottledBlock ()

@property (nonatomic, copy) void (^block)();
@property (assign, nonatomic) NSTimeInterval delay;

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation DGPThrottledBlock

- (instancetype)initWithBlock:(void (^)())block throttleDay:(NSTimeInterval)delay {
    self = [super init];
    if (self) {
        _block = block;
        _delay = delay;
    }
    return self;
}

- (void)start {
    if (self.timer.isValid) {
        [self.timer invalidate];
    }
    
    self.timer = [NSTimer timerWithTimeInterval:self.delay
                                         target:[self.block copy]
                                       selector:@selector(invoke)
                                       userInfo:nil
                                        repeats:NO];
    
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
}

@end
