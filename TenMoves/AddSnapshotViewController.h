//
//  AddSnapshotViewController.h
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snapshot.h"

@protocol AddSnapshowViewControllerDelegate;

@interface AddSnapshotViewController : UIViewController

@property (nonatomic, strong) id<AddSnapshowViewControllerDelegate> delegate;
@property (nonatomic, strong) Snapshot *currentSnapshot;

@end

@protocol AddSnapshowViewControllerDelegate

- (void)addSnapshotViewControllerDidSave;
- (void)addSnapshotViewControllerDidCancel:(Snapshot *)snapshotToDelete;

@end
