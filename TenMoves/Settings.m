//
//  Settings.m
//  TenMoves
//
//  Created by David Pedersen on 27/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "Settings.h"

@interface Settings ()

@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation Settings

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static Settings * sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _defaults = [NSUserDefaults standardUserDefaults];
        
        if ([_defaults objectForKey:[self makeKey:@"shareMovesWithAPI"]]) {
            _shareMovesWithAPI = [_defaults boolForKey:[self makeKey:@"shareMovesWithAPI"]];
        } else {
            _shareMovesWithAPI = YES;
        }
        
        [self addObservations];
    }
    return self;
}

- (void)dealloc {
    [self removeObservations];
}

#pragma mark - KVO

static void *DGPSomeContext = "DGPSomeContext";

- (void)addObservations {
    [self addObserver:self forKeyPath:@"shareMovesWithAPI"
              options:NSKeyValueObservingOptionNew
              context:DGPSomeContext];
}

- (void)removeObservations {
    [self removeObserver:self
              forKeyPath:@"shareMovesWithAPI"
                 context:DGPSomeContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == DGPSomeContext) {
        if (object == self) {
            if ([keyPath isEqualToString:@"shareMovesWithAPI"]) {
                [self.defaults setBool:self.shareMovesWithAPI forKey:[self makeKey:@"shareMovesWithAPI"]];
            }
            
            [self runInBackground:^{
                [self.defaults synchronize];
            }];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Helpers

- (NSString *)makeKey:(NSString *)key {
    return [NSString stringWithFormat:@"com.lonelyproton.TenMoves.Settings.%@", key];
}

- (void)runInBackground:(void (^)())block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

@end
