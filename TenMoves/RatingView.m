//
//  RatingView.m
//  TenMoves
//
//  Created by David Pedersen on 17/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "RatingView.h"

@interface RatingView ()

@property (strong, nonatomic) NSMutableArray *stars;

@property (assign, nonatomic) NSUInteger numberOfStars;
@property (assign, nonatomic) BOOL enableUserInteraction;

@end

@implementation RatingView

- (id)initWithFrame:(CGRect)frame
      numberOfStars:(NSUInteger)numberOfStars
enableUserInteraction:(BOOL)enableUserInteraction
           fontSize:(CGFloat)fontSize {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.stars = [NSMutableArray array];
        
        self.numberOfStars = numberOfStars;
        self.enableUserInteraction = enableUserInteraction;
        
        CGFloat starWidth = [self widthOfStarWidthFontSize:fontSize];
        CGFloat spaceWidth = (self.frame.size.width - self.numberOfStars * starWidth)/(self.numberOfStars+1);
        
        UILabel *star;
        
        for (int i = 1; i <= self.numberOfStars; i++) {
            CGRect frame = CGRectMake(spaceWidth*i+starWidth*(i-1), self.frame.size.height/2-starWidth/2, starWidth, starWidth);
            star = [[UILabel alloc] initWithFrame:frame];
            star.font = [UIFont systemFontOfSize:fontSize];
            [self disableStar:star];
            star.textColor = self.tintColor;
            star.userInteractionEnabled = self.enableUserInteraction;
            
            UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(starTapped:)];
            [star addGestureRecognizer:tapper];
            
            [self.stars addObject:star];
        }
        
        for (UILabel *star in self.stars) {
            [self addSubview:star];
        }
    }
    return self;
}

- (void)starTapped:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded) return;
    
    [self resetAllStars];
    
    UILabel *star = (UILabel *)gesture.view;
    for (UILabel *aStar in self.stars) {
        [self enableStar:aStar];
        if (aStar == star) break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ratingView:ratingDidChangeTo:outOf:)]) {
        [self.delegate ratingView:self ratingDidChangeTo:[self.stars indexOfObject:star]+1 outOf:self.numberOfStars];
    }
}

- (void)resetAllStars {
    for (UILabel *star in self.stars) {
        [self disableStar:star];
    }
}

- (void)disableStar:(UILabel *)star {
    star.text = @"☆";
}

- (void)enableStar:(UILabel *)star {
    star.text = @"★";
}

- (CGFloat)widthOfStarWidthFontSize:(CGFloat)fontSize {
    UILabel *star1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    star1.font = [UIFont systemFontOfSize:fontSize];
    star1.backgroundColor = [UIColor blackColor];
    star1.text = @"☆";
    star1.textColor = [UIColor blueColor];
    [star1 sizeToFit];
    return star1.frame.size.width;
}

- (void)selectStars:(NSUInteger)numberOfStarsToSelect {
    for (int i = 0; i < numberOfStarsToSelect; i++) {
        [self enableStar:self.stars[i]];
    }
}

@end
