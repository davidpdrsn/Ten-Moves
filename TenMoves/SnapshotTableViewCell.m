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
@import AssetsLibrary;

@interface SnapshotTableViewCell ()

@end

@implementation SnapshotTableViewCell

- (void)setSnapshot:(Snapshot *)snapshot {
    _snapshot = snapshot;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterMediumStyle;
    
    self.dateLabel.text = [formatter stringFromDate:snapshot.createdAt];
    
    [ALAssetsLibrary assetForURL:snapshot.videoUrl resultBlock:^(ALAsset *asset) {
        UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
        self.thumbnailImageView.image = image;
        self.thumbnailImageView.snapshot = snapshot;
    } failureBlock:^(NSError *error) {
        NSLog(@"image not found...");
    }];
}

- (void)setTintColor:(UIColor *)tintColor {
    [super setTintColor:tintColor];
    self.thumbnailImageView.tintColor = tintColor;
}

@end
