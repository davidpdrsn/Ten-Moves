//
//  ImageViewWithSnapshot.m
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "VideoPreview.h"
#import "Snapshot.h"
#import "SnapshotImage.h"
#import "SnapshotVideo.h"
@import MediaPlayer;
#import "VideoEditor.h"

@interface VideoPreview ()

@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIImageView *triangle;

@end

@implementation VideoPreview

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (!self.overlay) {
        self.overlay = [[UIView alloc] initWithFrame:self.bounds];
        [self updateBackground];
        [self addSubview:self.overlay];
        
        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tapper];
    }
    
    if (!self.triangle) {
        CGFloat width = self.frame.size.height/3.0;
        self.triangle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        self.triangle.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
        self.triangle.image = [UIImage imageNamed:@"triangle"];
        
        [self addSubview:self.triangle];
    }
    
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
}

- (void)tapped:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded || !self.enabled) return;
    
    MPMoviePlayerViewController *player = [[MPMoviePlayerViewController alloc] initWithContentURL:self.videoUrl];
    
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

- (void)setVideoUrl:(NSURL *)videoUrl {
    _videoUrl = videoUrl;
    
    [self updateBackground];
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    
    [self updateBackground];
}

- (void)updateBackground {
    self.overlay.backgroundColor = [self.tintColor colorWithAlphaComponent:0.5];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    [self updateBackground];
}

- (void)setHighlighted:(BOOL)highlighted {
    [self updateBackground];
}

- (void)setVideoAndImageFromSnapshot:(Snapshot *)snapshot {
    self.image = [snapshot cachedImage];
    self.videoUrl = [snapshot cachedVideo];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.125 animations:^{
            if (enabled) {
                self.overlay.backgroundColor = [self.tintColor colorWithAlphaComponent:.5];
            } else {
                self.overlay.backgroundColor = [[Snapshot colorForProgressType:SnapshotProgressBaseline] colorWithAlphaComponent:.5];
            }
        }];
    });
}

@end
