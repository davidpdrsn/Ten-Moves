//
//  AddSnapshotViewController.h
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddSnapshotTableViewControllerDelegate.h"

@class Snapshot;

@interface AddSnapshotTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) id<AddSnapshotTableViewControllerDelegate> delegate;
@property (nonatomic, strong) Snapshot *currentSnapshot;

@end