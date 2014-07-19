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

@end

@implementation RatingView

- (id)initWithFrame:(CGRect)frame
      numberOfStars:(NSUInteger)numberOfStars
           fontSize:(CGFloat)fontSize {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.stars = [NSMutableArray array];
        
        self.numberOfStars = numberOfStars;
        
        CGFloat starWidth = [Star widthOfStarWidthFontSize:fontSize];
        CGFloat spaceWidth = (self.frame.size.width - self.numberOfStars * starWidth)/(self.numberOfStars+1);
        
        Star *star;
        
        for (int i = 1; i <= self.numberOfStars; i++) {
            CGRect frame = CGRectMake(spaceWidth*i+starWidth*(i-1), self.frame.size.height/2-starWidth/2, starWidth, starWidth);
            star = [[Star alloc] initWithFrame:frame fontSize:fontSize delegate:self];
            star.textColor = self.tintColor;
            [self.stars addObject:star];
        }
        
        for (Star *star in self.stars) {
            [self addSubview:star];
        }
    }
    return self;
}

- (void)setUserInteractionEnabled:(BOOL)userInteractionEnabled {
    [super setUserInteractionEnabled:userInteractionEnabled];
    
    for (Star *star in self.stars) {
        star.userInteractionEnabled = userInteractionEnabled;
    }
}

- (void)resetAllStars {
    for (Star *star in self.stars) {
        [star unstar];
    }
}

- (void)selectStars:(NSUInteger)numberOfStarsToSelect {
    for (int i = 0; i < numberOfStarsToSelect; i++) {
        [self.stars[i] star];
    }
}

#pragma mark - star delegate methods

- (void)starTapped:(Star *)star {
    [self resetAllStars];
    
    for (Star *aStar in self.stars) {
        [aStar star];
        if (aStar == star) break;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(ratingView:ratingDidChangeTo:outOf:)]) {
        [self.delegate ratingView:self ratingDidChangeTo:[self.stars indexOfObject:star]+1 outOf:self.numberOfStars];
    }
}

@end
