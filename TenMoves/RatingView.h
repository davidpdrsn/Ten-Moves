//
//  RatingView.h
//  TenMoves
//
//  Created by David Pedersen on 17/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RatingViewDelegate;


@interface RatingView : UIView

@property (strong, nonatomic) NSObject<RatingViewDelegate> *delegate;

- (id)initWithFrame:(CGRect)frame
      numberOfStars:(NSUInteger)numberOfStars
enableUserInteraction:(BOOL)enableUserInteraction
           fontSize:(CGFloat)fontSize;

- (void)selectStars:(NSUInteger)numberOfStarsToSelect;

@end


@protocol RatingViewDelegate

@optional

- (void)ratingView:(RatingView *)ratingView ratingDidChangeTo:(NSUInteger)stars outOf:(NSUInteger)totalNumberOfStars;

@end