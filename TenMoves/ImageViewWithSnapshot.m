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
@property (strong, nonatomic) UIImageView *triangle;

@end

@implementation ImageViewWithSnapshot

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.overlay = [[UIView alloc] initWithFrame:self.bounds];
    self.overlay.backgroundColor = [self transparentBlue];
    [self addSubview:self.overlay];
    
    double width = 45.0/2.0;
    self.triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    self.triangle.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    self.triangle.image = [UIImage imageNamed:@"triangle"];
    
    [self addSubview:self.triangle];
}

- (UIColor *)transparentBlue {
    return [UIColor colorWithRed:86.0/255.0
                           green:169.0/255.0
                            blue:249.0/255.0
                           alpha:0.5];
}

@end
