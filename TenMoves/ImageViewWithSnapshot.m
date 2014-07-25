//
//  ImageViewWithSnapshot.m
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ImageViewWithSnapshot.h"
#import "Snapshot.h"
@import MediaPlayer;

@interface ImageViewWithSnapshot ()

@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) MPMoviePlayerController *player;

@end

@implementation ImageViewWithSnapshot

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _backgroundColor = [self.tintColor colorWithAlphaComponent:0.5];
    
    self.overlay = [[UIView alloc] initWithFrame:self.bounds];
    [self updateBackground];
    [self addSubview:self.overlay];
    
    CGFloat width = self.frame.size.height/3.0;
    UIImageView *triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
    triangle.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    triangle.image = [UIImage imageNamed:@"triangle"];
    
    [self addSubview:triangle];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tapper];
}

- (void)tapped:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded) return;
    
    ImageViewWithSnapshot *imageView = (ImageViewWithSnapshot *)gesture.view;
    Snapshot *snapshot = imageView.snapshot;
    
    self.player = [[MPMoviePlayerController alloc] initWithContentURL:[snapshot videoUrl]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:MPMoviePlayerWillExitFullscreenNotification
                                               object:nil];
    
    [self addSubview:self.player.view];
    [self.player.view setFrame:CGRectMake(self.overlay.frame.origin.x,
                                          self.overlay.frame.origin.y,
                                          20, 20)];
    [self.player setFullscreen:YES animated:YES];
    [self.player play];
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    [self.player.view removeFromSuperview];
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
