//
//  ProgressBaseView.m
//  TenMoves
//
//  Created by David Pedersen on 23/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ProgressPickerButton.h"

@interface ProgressPickerButton ()

@end

@implementation ProgressPickerButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSLog(@"view did load was called");
    }
    return self;
}

- (void)resizeToFit:(CGRect)parentFrame {
    CGFloat width = parentFrame.size.width/3;
    CGFloat height = parentFrame.size.height;
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, height);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    
    animation.fromValue = (id)[UIColor clearColor].CGColor;
    animation.toValue = (id)[UIColor magentaColor].CGColor;
    animation.duration = .15;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.delegate = self;
    
    [self.layer addAnimation:animation forKey:@"in"];
    
    self.backgroundColor = [UIColor magentaColor];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    animation.fromValue = (id)self.backgroundColor.CGColor;
    animation.toValue = (id)[UIColor clearColor].CGColor;
    animation.duration = .15;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [self.layer addAnimation:animation forKey:@"out"];
    self.backgroundColor = [UIColor clearColor];
}

@end
