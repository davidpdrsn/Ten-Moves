//
//  UIView+Autolayout.h
//  TenMoves
//
//  Created by David Pedersen on 07/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Autolayout)

+ (instancetype)autolayoutView;

- (void)constrainCenterHorizontallyOffset:(CGFloat)offset;
- (void)constrainCenterVerticallyOffset:(CGFloat)offset;
- (void)constrainCenterHorizontally;
- (void)constrainCenterVertically;
- (void)constrainCenter;

- (void)constrainWidthToEqualHeight;
- (void)constrainHeightToEqualWidth;

- (void)constrainWidthToEqual:(CGFloat)width;
- (void)constrainHeightToEqual:(CGFloat)height;
- (void)constrainWidthToRatio:(CGFloat)ratio;
- (void)constrainHeightToRatio:(CGFloat)ratio;

- (void)constrainFlushLeft;
- (void)constrainFlushLeftOffset:(CGFloat)offset;
- (void)constrainFlushRight;
- (void)constrainFlushRightOffset:(CGFloat)offset;
- (void)constrainFlushLeftRight;
- (void)constrainFlushTop;
- (void)constrainFlushTopOffset:(CGFloat)offset;
- (void)constrainFlushBottom;
- (void)constrainFlushBottomOffset:(CGFloat)offset;
- (void)constrainFlushTopBottom;
- (void)constrainFlush;

@end
