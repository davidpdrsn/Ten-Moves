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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
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
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"|[view]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"view": self}]];
}

- (void)constrainFlushTopBottom {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self.superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat: @"V:|[view]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:@{@"view": self}]];
}

@end
