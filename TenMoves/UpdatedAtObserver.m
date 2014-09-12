//
//  UpdatedAtObserver.m
//  TenMoves
//
//  Created by David Pedersen on 12/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "UpdatedAtObserver.h"

@interface UpdatedAtObserver ()

@property (strong, nonatomic) NSArray *keyPaths;
@property (strong, nonatomic) id object;

@end

@implementation UpdatedAtObserver

- (instancetype)initWithKeyPaths:(NSArray *)keyPaths object:(id)object {
    self = [super init];
    if (self) {
        _keyPaths = keyPaths;
        _object = object;

        for (NSString *keyPath in _keyPaths) {
            [object addObserver:self forKeyPath:keyPath options:0 context:NULL];
        }
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    for (NSString *keyPathTriggeringUpdate in self.keyPaths) {
        SEL selector = NSSelectorFromString(@"setUpdatedAt:");

        if ([keyPathTriggeringUpdate isEqualToString:keyPath] && [self.object respondsToSelector:selector]) {
            NSDate *now = [NSDate date];

            IMP imp = [self.object methodForSelector:selector];
            void (*func)(id, SEL, NSDate*) = (void *)imp;
            func(self.object, selector, now);
            break;
        }
    }
}

@end
