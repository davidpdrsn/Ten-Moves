//
//  AddSnapshotViewController.h
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddSnapshotTableViewControllerDelegate.h"
#import "ImageViewWithSnapshotDelegate.h"
#import "JTSTextView.h"

@class Snapshot;

@interface AddSnapshotTableViewController : UITableViewController
<
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    ImageViewWithSnapshotDelegate,
    JTSTextViewDelegate
>

@property (nonatomic, weak) id<AddSnapshotTableViewControllerDelegate> delegate;
@property (nonatomic, strong) Snapshot *currentSnapshot;

@property (nonatomic, assign) BOOL editingSnapshot;

@end