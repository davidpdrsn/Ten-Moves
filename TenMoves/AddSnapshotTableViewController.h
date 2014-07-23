//
//  AddSnapshotViewController.h
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snapshot.h"

@protocol AddSnapshowTableViewControllerDelegate;

@interface AddSnapshotTableViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) id<AddSnapshowTableViewControllerDelegate> delegate;
@property (nonatomic, strong) Snapshot *currentSnapshot;

@end

@protocol AddSnapshowTableViewControllerDelegate

- (void)addSnapshotTableViewControllerDidSave;
- (void)addSnapshotTableViewControllerDidCancel:(Snapshot *)snapshotToDelete;

@end
