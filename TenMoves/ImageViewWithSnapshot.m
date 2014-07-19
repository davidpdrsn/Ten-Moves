//
//  ImageViewWithSnapshot.m
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ImageViewWithSnapshot.h"

@interface ImageViewWithSnapshot ()

@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIColor *backgroundColor;

@end

@implementation ImageViewWithSnapshot

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _backgroundColor = [self.tintColor colorWithAlphaComponent:0.5];
    
    self.overlay = [[UIView alloc] initWithFrame:self.bounds];
    [self updateBackground];
    [self addSubview:self.overlay];
    
    double width = 45.0/2.0;
    UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    triangle.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    triangle.image = [UIImage imageNamed:@"triangle"];
    
    [self addSubview:triangle];
}

- (void)updateBackground {
    self.overlay.backgroundColor = [self.tintColor colorWithAlphaComponent:0.5];
}

- (void)setTintColor:(UIColor *)tintColor {
    _backgroundColor = tintColor;
    [self updateBackground];
}

- (void)setHighlighted:(BOOL)highlighted {
    [self updateBackground];
}

@end
