//
//  CALayer+SizingAndPositioning.h
//  TenMoves
//
//  Created by David Pedersen on 07/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (SizingAndPositioning)

- (void)setSize:(CGFloat)size;
- (void)setSizeToRatio:(CGFloat)ratio;

- (void)center;
- (void)centerWithVerticalOffset:(CGFloat)offset;
- (void)centerWithHorizontalOffset:(CGFloat)offset;

- (void)alignRight;
- (void)alignLeft;

- (void)makeCircle;

@end
