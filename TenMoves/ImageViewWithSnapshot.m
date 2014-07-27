//
//  ImageViewWithSnapshot.m
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ImageViewWithSnapshot.h"
#import "Snapshot.h"
#import "SnapshotImage.h"
#import "SnapshotVideo.h"
@import MediaPlayer;

@interface ImageViewWithSnapshot ()

@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIColor *backgroundColor;

@end

@implementation ImageViewWithSnapshot

- (void)awakeFromNib {
    [super awakeFromNib];
    
    // TODO: why does the date label not show up?!
    
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
    
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:[snapshot.video url]];
    
    [[NSNotificationCenter defaultCenter] removeObserver:player
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player.moviePlayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieFinishedCallback:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:player.moviePlayer];
    
    [player.moviePlayer prepareToPlay];
    
    if (self.delegate) {
        [self.delegate imageViewWithSnapshot:self presentMoviePlayerViewControllerAnimated:player];
    }
}
- (void)movieFinishedCallback:(NSNotification *)notification {
    NSNumber *finishReason = [[notification userInfo] objectForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey];
    
    if ([finishReason intValue] != MPMovieFinishReasonPlaybackEnded) {
        MPMoviePlayerController *moviePlayer = [notification object];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:MPMoviePlayerPlaybackDidFinishNotification
                                                      object:moviePlayer];
        
        if (self.delegate) {
            [self.delegate imageViewWithSnapshotDismissMoviePlayerViewControllerAnimated:self];
        }
    }
}

- (void)setSnapshot:(Snapshot *)snapshot {
    _snapshot = snapshot;
    self.image = [snapshot.image image];
    [self updateBackground];
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
