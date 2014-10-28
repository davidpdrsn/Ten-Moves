//
//  UIView+Autolayout.m
//  TenMoves
//
//  Created by David Pedersen on 07/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "UIView+Autolayout.h"

@implementation UIView (Autolayout)

+ (instancetype)autolayoutView {
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

#pragma mark - Centering

- (void)constrainCenter {
    [self constrainCenterHorizontally];
    [self constrainCenterVertically];
}

- (void)constrainCenterHorizontally {
    [self constrainCenterHorizontallyOffset:0];
}

- (void)constrainCenterHorizontallyOffset:(CGFloat)offset {
    [self prepare];
    
    NSLayoutConstraint *xCenterConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.superview
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1.0
                                                                          constant:offset];
    [self.superview addConstraint:xCenterConstraint];
}

- (void)constrainCenterVertically {
    [self constrainCenterVerticallyOffset:0];
}

- (void)constrainCenterVerticallyOffset:(CGFloat)offset {
    [self prepare];
    
    NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.superview
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1.0
                                                                          constant:offset];
    [self.superview addConstraint:yCenterConstraint];
}

#pragma mark - Equal width and height

- (void)constrainWidthToEqualHeight {
    [self prepare];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1
                                                                   constant:0];
    [self.superview addConstraint:constraint];
}

- (void)constrainHeightToEqualWidth {
    [self prepare];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1
                                                                   constant:0];
    [self.superview addConstraint:constraint];
}

#pragma mark - Width and height

- (void)constrainWidthToEqual:(CGFloat)width {
    [self prepare];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:0
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1
                                                                   constant:width];
    [self.superview addConstraint:constraint];
}

- (void)constrainHeightToEqual:(CGFloat)height {
    [self prepare];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:0
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:1
                                                                   constant:height];
    [self.superview addConstraint:constraint];
}

- (void)constrainWidthToRatio:(CGFloat)ratio {
    [self prepare];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeWidth
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.superview
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:ratio
                                                                   constant:0];
    [self.superview addConstraint:constraint];
}

- (void)constrainHeightToRatio:(CGFloat)ratio {
    [self prepare];
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.superview
                                                                  attribute:NSLayoutAttributeHeight
                                                                 multiplier:ratio
                                                                   constant:0];
    [self.superview addConstraint:constraint];
}

#pragma mark - Flushing...

- (void)constrainFlush {
    [self constrainFlushLeftRight];
    [self constrainFlushTopBottom];
}

- (void)constrainFlushLeftRight {
    [self constrainFlushRight];
    [self constrainFlushLeft];
}

- (void)constrainFlushLeft {
    [self prepare];
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"|[view]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"view": self}]];
}

- (void)constrainFlushLeftOffset:(CGFloat)offset {
    [self prepare];
    
    NSDictionary *metrics = @{ @"offset": [NSNumber numberWithFloat:offset] };
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"|-offset-[view]"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:@{@"view": self}]];
}

- (void)constrainFlushRightOffset:(CGFloat)offset {
    [self prepare];
    
    NSDictionary *metrics = @{ @"offset": [NSNumber numberWithFloat:offset] };
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"[view]-offset-|"
                                                                           options:0
                                                                           metrics:metrics
                                                                             views:@{@"view": self}]];
}


- (void)constrainFlushRight {
    [self prepare];
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"[view]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"view": self}]];
}

- (void)constrainFlushTop {
    [self prepare];
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|[view]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"view": self}]];
}

- (void)constrainFlushTopOffset:(CGFloat)offset {
    [self prepare];

    NSDictionary *metrics = @{ @"offset": [NSNumber numberWithFloat:offset] };
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|-offset-[view]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:@{@"view": self}]];
}

- (void)constrainFlushBottom {
    [self prepare];
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:[view]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"view": self}]];
}

- (void)constrainFlushBottomOffset:(CGFloat)offset {
    [self prepare];

    NSDictionary *metrics = @{ @"offset": [NSNumber numberWithFloat:offset] };
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:[view]-offset-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:@{@"view": self}]];
}

- (void)constrainFlushTopBottom {
    [self prepare];
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|[view]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"view": self}]];
}

#pragma mark - Helpers

- (void)prepare {
    assert(self.superview != nil);
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

@end
