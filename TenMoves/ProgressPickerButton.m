//
//  ProgressBaseView.m
//  TenMoves
//
//  Created by David Pedersen on 23/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ProgressPickerButton.h"
#import "Snapshot.h"
#import "UIView+Autolayout.h"
#import "CALayer+SizingAndPositioning.h"

@interface ProgressPickerButton () {
    BOOL _active;
}

@property (strong, nonatomic) CALayer *circle;
@property (strong, nonatomic) CALayer *innerCircle;
@property (strong, nonatomic) CALayer *border;

@property (strong, nonatomic) UIColor *circleColor;

@end

@implementation ProgressPickerButton

- (instancetype)init {
    self = [super init];
    if (self) {
        _label = [UILabel autolayoutView];
        _label.userInteractionEnabled = NO;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.userInteractionEnabled = NO;
        _label.text = @"Label";
        _label.font = [UIFont systemFontOfSize:12];
        
        _circle = [CALayer layer];
        _innerCircle = [CALayer layer];
        _innerCircle.backgroundColor = [UIColor whiteColor].CGColor;
        
        _active = NO;
        _hasBorder = NO;
        
        [self addSubview:_label];
        [self.layer addSublayer:_circle];
        [_circle addSublayer:_innerCircle];
        
        [self addObserver:self forKeyPath:@"type" options:NSKeyValueObservingOptionNew context:nil];
        
        [_label constrainCenterHorizontally];
        [_label constrainCenterVerticallyOffset:25];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"type"]) {
        self.circle.backgroundColor = [Snapshot colorForProgressType:self.type].CGColor;
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutCircle];
    [self layoutInnerCircle];
    if (self.hasBorder) {
        [self layoutBorder];
    }
}

- (void)layoutCircle {
    [self.circle setSize:self.frame.size.height/2];
    [self.circle centerWithVerticalOffset:-10];
    [self.circle centerWithHorizontalOffset:0];
    [self.circle makeCircle];
}

- (void)layoutInnerCircle {
    if (_active) {
        [self.innerCircle setSizeToRatio:.75];
    } else {
        [self.innerCircle setSizeToRatio:0];
    }
    
    [self.innerCircle center];
    [self.innerCircle makeCircle];
}

- (void)layoutBorder {
    if (!self.border) {
        self.border = [CALayer layer];
        self.border.frame = CGRectMake(0, 0, .5, self.frame.size.height);
        self.border.backgroundColor = [[UITableView alloc] init].separatorColor.CGColor;
        [self.layer addSublayer:self.border];
    }
    
    [self.border alignRight];
}

- (void)setActive:(BOOL)active animated:(BOOL)animated {
    if (_active == active) return;
    _active = active;
    [self layoutInnerCircle];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    if (enabled) {
        self.circle.backgroundColor = [Snapshot colorForProgressType:self.type].CGColor;
    } else {
        self.circle.backgroundColor = [[Snapshot colorForProgressType:SnapshotProgressBaseline] colorWithAlphaComponent:.5].CGColor;
    }
}

@end
