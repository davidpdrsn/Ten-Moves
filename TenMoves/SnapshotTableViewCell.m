//
//  SnapshotTableViewCell.m
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "SnapshotTableViewCell.h"
#import "ALAssetsLibrary+HelperMethods.h"
#import "VideoPreview.h"
#import "Snapshot.h"
#import "SnapshotVideo.h"
#import "UIView+Autolayout.h"
@import AssetsLibrary;

@interface SnapshotTableViewCell ()

@property (strong, nonatomic) UILabel *dateLabel;
@property (strong, nonatomic) UIView *progressIndicator;

@end

@implementation SnapshotTableViewCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self) return nil;

    _dateLabel = [UILabel autolayoutView];
    _progressIndicator = [UIView autolayoutView];
    _thumbnailImageView = [VideoPreview autolayoutView];

    [self addSubview:_dateLabel];
    [self addSubview:_progressIndicator];
    [self addSubview:_thumbnailImageView];

    [self addObservations];

    return self;
}

- (void)dealloc {
    [self removeObservations];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)updateConstraints {
    NSDictionary *views = @{
                            @"thumbnail": self.thumbnailImageView,
                            @"date": self.dateLabel,
                            @"progress": self.progressIndicator
                            };

    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[thumbnail]-[date]-[progress(20)]-|"
                                                                                    options:0
                                                                                    metrics:nil
                                                                                      views:views]];

    [self.progressIndicator constrainWidthToEqual:20];
    [self.progressIndicator constrainHeightToEqual:20];

    [self.thumbnailImageView constrainHeightToRatio:.9];
    [self.thumbnailImageView constrainWidthToEqualHeight];

    [self.thumbnailImageView constrainCenterVertically];
    [self.dateLabel constrainCenterVertically];
    [self.progressIndicator constrainCenterVertically];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:self.thumbnailImageView
                                                     attribute:NSLayoutAttributeLeftMargin
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self.thumbnailImageView
                                                     attribute:NSLayoutAttributeTopMargin
                                                    multiplier:1
                                                      constant:0]];

    [super updateConstraints];
}

static void * LPSomeContext = "LPSnapshotCell";

#pragma mark - KVO

- (void)addObservations {
    [self addObserver:self forKeyPath:@"snapshot" options:NSKeyValueObservingOptionNew context:LPSomeContext];
    [self.thumbnailImageView addObserver:self forKeyPath:@"enabled" options:NSKeyValueObservingOptionNew context:LPSomeContext];
}

- (void)removeObservations {
    [self removeObserver:self forKeyPath:@"snapshot" context:LPSomeContext];
    [self.thumbnailImageView removeObserver:self forKeyPath:@"enabled" context:LPSomeContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == LPSomeContext) {
        if (object == self) {
            if ([keyPath isEqualToString:@"snapshot"]) {
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.dateStyle = NSDateFormatterMediumStyle;
                
                self.dateLabel.text = [formatter stringFromDate:self.snapshot.createdAt];
                
                [self.thumbnailImageView setVideoAndImageFromSnapshot:self.snapshot];
                [self.thumbnailImageView awakeFromNib];

                NSLog(@"%@", self.snapshot.video.path);
                
                [self setupProgressIndicator];
            }
        } else if (object == self.thumbnailImageView) {
            if ([keyPath isEqualToString:@"enabled"]) {
                if (self.thumbnailImageView.enabled) {
                    [self setupProgressIndicator];
                } else {
                    self.progressIndicator.backgroundColor = [Snapshot colorForProgressType:SnapshotProgressBaseline];
                }
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)setupProgressIndicator {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressIndicator.backgroundColor = [Snapshot colorForProgressType:self.snapshot.progressTypeRaw];
        self.progressIndicator.layer.cornerRadius = self.progressIndicator.frame.size.height/2;

        [self setProgressIndicatorBackground];
        
        self.progressIndicator.accessibilityLabel =
        [Snapshot textForProgressType:self.snapshot.progressTypeRaw];
    });
}

- (void)setProgressIndicatorBackground {
    self.progressIndicator.backgroundColor = [self.snapshot colorForProgressType];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [self setProgressIndicatorBackground];
}

@end
