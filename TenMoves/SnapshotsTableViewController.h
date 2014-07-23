//
//  SnapshotsTableViewController.h
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+EmptyDataSet.h"
#import "AddSnapshotTableViewControllerDelegate.h"

@class Snapshot;
@class Move;
@class AddMoveViewController;

@interface SnapshotsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, AddSnapshotTableViewControllerDelegate>

@property (nonatomic, strong) Move *move;

@end
