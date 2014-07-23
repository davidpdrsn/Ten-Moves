//
//  SnapshotsTableViewController.h
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snapshot.h"
#import "Move.h"
#import "AddSnapshotTableViewController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface SnapshotsTableViewController : UITableViewController <NSFetchedResultsControllerDelegate, AddSnapshowTableViewControllerDelegate>

@property (nonatomic, strong) Move *move;

@end
