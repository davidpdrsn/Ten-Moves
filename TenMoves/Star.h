//
//  Star.h
//  TenMoves
//
//  Created by David Pedersen on 18/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StarDelegate;

@interface Star : UILabel

+ (CGFloat)widthOfStarWidthFontSize:(CGFloat)fontSize;

@property (strong, nonatomic) NSObject<StarDelegate> *delegate;

- (id)initWithFrame:(CGRect)frame fontSize:(CGFloat)fontSize delegate:(NSObject<StarDelegate> *)delegate;

- (void)star;
- (void)unstar;

@end

@protocol StarDelegate

@optional

- (void)starTapped:(Star *)star;

@end