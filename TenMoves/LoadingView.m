//
//  LoadingView.m
//  TenMoves
//
//  Created by David Pedersen on 29/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

- (void)setHidden:(BOOL)hidden {
    assert(self.superview != nil);
    
    if (hidden) {
        self.superview.userInteractionEnabled = YES;
        
        [UIView animateWithDuration:.13 animations:^{
            self.frame = CGRectMake(self.frame.origin.x,
                                                self.frame.origin.y - 20,
                                                self.frame.size.width,
                                                self.frame.size.height);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.4 animations:^{
                self.frame = CGRectMake(self.frame.origin.x,
                                        self.frame.origin.y + self.superview.frame.size.height*.75,
                                        self.frame.size.width,
                                        self.frame.size.height);
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        }];
    } else {
        self.superview.userInteractionEnabled = NO;
        
        CGRect frame = CGRectMake(0, 0, 120, 120);
        self.frame = frame;
        self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.75];
        self.layer.cornerRadius = 5;
        
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        spinner.hidden = NO;
        
        [spinner startAnimating];
        [self centerView:spinner inSuperView:self];
        
        UILabel *label = [[UILabel alloc] init];
        label.text = @"Importing";
        label.font = [UIFont boldSystemFontOfSize:label.font.pointSize];
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        
        [self addSubview:label];
        [self centerView:label inSuperView:self];
        
        [self addSubview:spinner];
        [self centerView:spinner inSuperView:self];
        
        [self centerView:self inSuperView:self.superview];
        
        [self adjustCenterX:0 y:35 inView:label];
        [self adjustCenterX:0 y:-5 inView:spinner];
        double delta = -7;
        [self adjustCenterX:0 y:delta inView:label];
        [self adjustCenterX:0 y:delta inView:spinner];
        [self adjustCenterX:0 y:-5 inView:self];
    }
}

- (void)adjustCenterX:(double)deltaX y:(double)deltaY inView:(UIView *)view {
    view.center = CGPointMake(view.center.x+deltaX, view.center.y+deltaY);
}

- (void)centerView:(UIView *)view inSuperView:(UIView *)superView {
    CGRect oldFrame = view.bounds;
    CGRect superFrame = superView.bounds;
    
    view.frame = CGRectMake(superFrame.size.width/2 - oldFrame.size.width/2,
                            superFrame.size.height/2 - oldFrame.size.height/2,
                            oldFrame.size.width, oldFrame.size.height);
}


@end
