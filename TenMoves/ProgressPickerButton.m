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

@interface ProgressPickerButton ()

@property (strong, nonatomic) CALayer *border;
@property (strong, nonatomic) CALayer *innerCircle;
@property (strong, nonatomic) UIImageView *circle;
@property (strong, nonatomic) UILabel *label;
@property (assign, nonatomic) BOOL isActive;

@end

@implementation ProgressPickerButton

- (void)awakeFromNib {
    [super awakeFromNib];
    [self resizeToFit:self.superview.frame];
//    self.backgroundColor = [UIColor clearColor];
    self.isActive = NO;
    
    [self constrainWidthToEqual:10];
}

- (void)resizeToFit:(CGRect)parentFrame {
    CGFloat width = parentFrame.size.width/3;
    CGFloat height = parentFrame.size.height;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
}

- (void)setShowBorder:(BOOL)shouldShowBorder {
    if (shouldShowBorder) {
        CALayer *rightBorder = [CALayer layer];
        rightBorder.frame = CGRectMake(self.frame.size.width, 0, 0.5f, [self superview].frame.size.height);
        rightBorder.backgroundColor = [[UITableView alloc] init].separatorColor.CGColor;
        
        [self.layer addSublayer:rightBorder];
        
        self.border = rightBorder;
    } else {
        self.border = nil;
    }
}

- (void)setActive:(BOOL)shouldBeActive {
    if (shouldBeActive == self.isActive) return;
    _isActive = shouldBeActive;
    
    CGFloat toSize = (shouldBeActive) ? self.circle.frame.size.height-11 : 0;
    
    [CATransaction begin];
    [CATransaction setValue:@(.2) forKey:kCATransactionAnimationDuration];
    self.innerCircle.bounds = CGRectMake(self.innerCircle.bounds.origin.x,
                                         self.innerCircle.bounds.origin.y,
                                         toSize,
                                         toSize);
    self.innerCircle.cornerRadius = toSize/2;
    [CATransaction commit];
}

- (void)setProgressType:(SnapshotProgress)type {
    _type = type;
    
    UIColor *color = [Snapshot colorForProgressType:type];
    CGFloat size = self.frame.size.height/2;
    CGRect frame = CGRectMake(self.frame.size.width/2 - size/2,
                              self.frame.size.height/2 - size/2 - 7,
                              size,
                              size);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = color;
    imageView.layer.cornerRadius = size/2;
    
    CALayer *innerCircle = [[CALayer alloc] init];
    int innerCircleSize = 0;
    innerCircle.frame = CGRectMake(size/2-innerCircleSize/2, size/2-innerCircleSize/2, innerCircleSize, innerCircleSize);
    innerCircle.backgroundColor = [UIColor whiteColor].CGColor;
    
    self.circle = imageView;
    self.innerCircle = innerCircle;
    
    [imageView.layer addSublayer:innerCircle];
    [self addSubview:imageView];
}

- (void)setLabelText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    label.font = [UIFont systemFontOfSize:12];
    [label sizeToFit];
    self.label = label;
    [self addSubview:label];
    
    [self.label constrainCenter];
}

- (void)setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    [UIView animateWithDuration:.125 animations:^{
        if (enabled) {
            self.circle.backgroundColor = [Snapshot colorForProgressType:self.type];
            self.label.textColor = [UIColor blackColor];
        } else {
            self.circle.backgroundColor = [[Snapshot colorForProgressType:SnapshotProgressBaseline] colorWithAlphaComponent:.33333];
            self.label.textColor = [Snapshot colorForProgressType:SnapshotProgressBaseline];
        }
    }];
}

@end
