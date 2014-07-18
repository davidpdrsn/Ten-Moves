//
//  Star.m
//  TenMoves
//
//  Created by David Pedersen on 18/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "Star.h"

@implementation Star

+ (CGFloat)widthOfStarWidthFontSize:(CGFloat)fontSize {
    Star *star = [[Star alloc] initWithFrame:CGRectMake(0, 0, 30, 30) fontSize:fontSize delegate:nil];
    [star sizeToFit];
    return star.frame.size.width;
}

- (id)initWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize delegate:(NSObject<StarDelegate> *)delegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = delegate;
        
        self.text = @"☆";
        self.font = [UIFont systemFontOfSize:fontSize];
        self.textColor = self.tintColor;
    }
    return self;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    [self addGestureRecognizer:tapper];
}

- (void)tapped:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded) return;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(starTapped:)]) {
        [self.delegate starTapped:self];
    }
}

- (void)star {
    self.text = @"★";
}

- (void)unstar {
    self.text = @"☆";
}

@end
