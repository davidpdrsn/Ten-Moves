//
//  ImageViewWithSnapshotDelegate.h
//  TenMoves
//
//  Created by David Pedersen on 27/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoPreview, MPMoviePlayerViewController;

@protocol ImageViewWithSnapshotDelegate

- (void)imageViewWithSnapshot:(VideoPreview *)imageView presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)player;
- (void)imageViewWithSnapshotDismissMoviePlayerViewControllerAnimated:(VideoPreview *)imageView;

@end
