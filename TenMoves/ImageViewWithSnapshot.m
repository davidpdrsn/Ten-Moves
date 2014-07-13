//
//  ImageViewWithSnapshot.m
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ImageViewWithSnapshot.h"

@implementation ImageViewWithSnapshot

- (void)awakeFromNib {
    [super awakeFromNib];
    
    UIView *overlay = [[UIView alloc] initWithFrame:self.bounds];
    overlay.backgroundColor = [self transparentBlue];
    [self addSubview:overlay];
    
    double width = 45.0/2.0;
    UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    triangle.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    triangle.image = [UIImage imageNamed:@"triangle"];
    
    [self addSubview:triangle];
}

- (UIColor *)transparentBlue {
    return [UIColor colorWithRed:86.0/255.0
                           green:169.0/255.0
                            blue:249.0/255.0
                           alpha:0.5];
}

@end
