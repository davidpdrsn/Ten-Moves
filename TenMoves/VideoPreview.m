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
@import AVKit;
@import AVFoundation;
#import "VideoEditor.h"
#import "UIView+Autolayout.h"

@interface VideoPreview ()

@property (strong, nonatomic) UIView *overlay;
@property (strong, nonatomic) UIImageView *triangle;

@end

@implementation VideoPreview

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (!self.overlay) {
        self.overlay = [UIView autolayoutView];
        
        [self updateBackground];
        [self addSubview:self.overlay];
        
        [self.overlay constrainFlush];

        UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tapper];

        self.accessibilityTraits = UIAccessibilityTraitButton | UIAccessibilityTraitImage;
    }
    
    if (!self.triangle) {
        self.triangle = [UIImageView autolayoutView];
        self.triangle.image = [UIImage imageNamed:@"triangle"];
        
        [self addSubview:self.triangle];
        
        [self.triangle constrainHeightToRatio:.333];
        [self.triangle constrainWidthToEqualHeight];
        [self.triangle constrainCenter];
    }
    
    self.contentMode = UIViewContentModeScaleAspectFill;
    self.clipsToBounds = YES;
    self.enabled = YES;
}

- (void)tapped:(UIGestureRecognizer *)gesture {
    if (gesture.state != UIGestureRecognizerStateEnded || !self.enabled) return;
    assert(self.delegate != nil);

    AVPlayer *player = [AVPlayer playerWithURL:self.videoUrl];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;

    [self.delegate imageViewWithSnapshot:self presentMoviePlayerViewControllerAnimated:playerViewController];
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

- (void)setHighlighted:(BOOL)highlighted {
    [self updateBackground];
}

- (void)setVideoAndImageFromSnapshot:(Snapshot *)snapshot {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    NSString *dateString = [formatter stringFromDate:snapshot.createdAt];
    NSString *label = [NSString stringWithFormat:@"Play video from %@", dateString];
    self.accessibilityLabel = label;

    self.image = [snapshot cachedImage];
    self.videoUrl = [snapshot cachedVideo];
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:.125 animations:^{
            if (enabled) {
                [self updateBackground];
            } else {
                self.overlay.backgroundColor = [[Snapshot colorForProgressType:SnapshotProgressBaseline] colorWithAlphaComponent:.5];
            }
        }];
    });
}

@end
