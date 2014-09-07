//
//  CALayer+SizingAndPositioning.m
//  TenMoves
//
//  Created by David Pedersen on 07/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "CALayer+SizingAndPositioning.h"

@implementation CALayer (SizingAndPositioning)

#pragma mark - Positioning

- (void)center {
    [self centerWithVerticalOffset:0];
    [self centerWithHorizontalOffset:0];
}

- (void)centerWithHorizontalOffset:(CGFloat)offset {
    CGRect frame = self.frame;
    frame.origin = CGPointMake(self.superlayer.frame.size.width/2 - self.frame.size.width/2 + offset, self.frame.origin.y);
    self.frame = frame;
}

- (void)centerWithVerticalOffset:(CGFloat)offset {
    CGRect frame = self.frame;
    frame.origin = CGPointMake(self.frame.origin.x, self.superlayer.frame.size.height/2 - self.frame.size.height/2 + offset);
    self.frame = frame;
}

- (void)alignRight {
    CGRect frame = self.frame;
    frame.origin = CGPointMake(self.superlayer.frame.size.width, self.frame.origin.y);
    self.frame = frame;
}

- (void)alignLeft {
    CGRect frame = self.frame;
    frame.origin = CGPointMake(self.frame.size.width, self.frame.origin.y);
    self.frame = frame;
}

#pragma mark - Sizing

- (void)setSize:(CGFloat)size {
    CGRect frame = self.frame;
    frame.size.height = size;
    frame.size.width = size;
    self.frame = frame;
}

- (void)setSizeToRatio:(CGFloat)ratio {
    CGRect frame = self.frame;
    frame.size.height = self.superlayer.frame.size.height * ratio;
    frame.size.width = self.superlayer.frame.size.width * ratio;
    self.frame = frame;
}

#pragma mark - Misc

- (void)makeCircle {
    self.cornerRadius = self.frame.size.height/2;
}

#pragma mark - Helpers

- (void)prepare {
    assert(self.superlayer != nil);
}

@end
