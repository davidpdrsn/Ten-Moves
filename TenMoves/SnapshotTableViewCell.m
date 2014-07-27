//
//  SnapshotTableViewCell.m
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "SnapshotTableViewCell.h"
#import "ALAssetsLibrary+HelperMethods.h"
#import "ImageViewWithSnapshot.h"
#import "Snapshot.h"
#import "Constants.h"
@import AssetsLibrary;

@interface SnapshotTableViewCell ()

@end

@implementation SnapshotTableViewCell

- (void)setupProgressIndicator {
    self.progressIndicator.layer.cornerRadius = self.progressIndicator.frame.size.height/2;
    self.progressIndicator.backgroundColor = [self.snapshot colorForProgressType];
}

- (void)setSnapshot:(Snapshot *)snapshot {
    _snapshot = snapshot;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    
    self.dateLabel.text = [formatter stringFromDate:snapshot.createdAt];
    
    [self setupProgressIndicator];
    
    self.thumbnailImageView.snapshot = snapshot;
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.thumbnailImageView.tintColor = tintColor;
}

@end
