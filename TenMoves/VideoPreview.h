//
//  ImageViewWithSnapshot.h
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewWithSnapshotDelegate.h"

@class Snapshot;

@interface VideoPreview : UIImageView

@property (strong, nonatomic) NSURL *videoUrl;
@property (strong, nonatomic) id<ImageViewWithSnapshotDelegate> delegate;

- (void)updateBackground;

- (void)setVideoAndImageFromSnapshot:(Snapshot *)snapshot;

@end
