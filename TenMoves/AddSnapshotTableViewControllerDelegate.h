//
//  AddSnapshowTableViewControllerDelegate.h
//  TenMoves
//
//  Created by David Pedersen on 23/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Snapshot;

@protocol AddSnapshotTableViewControllerDelegate

- (void)addSnapshotTableViewControllerDidSave;
- (void)addSnapshotTableViewControllerDidCancel:(Snapshot *)snapshotToDelete;

@optional

- (void)dismissAddSnapshotTableViewController;

@end
