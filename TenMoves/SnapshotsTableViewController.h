//
//  SnapshotsTableViewController.h
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+EmptyDataSet.h"
#import "ImageViewWithSnapshotDelegate.h"

@class Snapshot;
@class Move;
@class AddMoveTableViewController;

@interface SnapshotsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, ImageViewWithSnapshotDelegate>

@property (nonatomic, strong) Move *move;

@end
