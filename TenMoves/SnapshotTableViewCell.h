//
//  SnapshotTableViewCell.h
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewWithSnapshot.h"
#import "Snapshot.h"

@interface SnapshotTableViewCell : UITableViewCell

@property (strong, nonatomic) Snapshot *snapshot;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet ImageViewWithSnapshot *thumbnailImageView;

@end
