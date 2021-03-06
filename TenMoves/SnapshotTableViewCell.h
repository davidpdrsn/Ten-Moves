//
//  SnapshotTableViewCell.h
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoPreview;
@class Snapshot;

@interface SnapshotTableViewCell : UITableViewCell

@property (strong, nonatomic) Snapshot *snapshot;

@property (strong, nonatomic) VideoPreview *thumbnailImageView;

- (void)setProgressIndicatorBackground;

@end
