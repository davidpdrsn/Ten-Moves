//
//  ShowSnapshotViewController.h
//  TenMoves
//
//  Created by David Pedersen on 30/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewWithSnapshotDelegate.h"

@class Snapshot;

@interface ShowSnapshotViewController : UIViewController <ImageViewWithSnapshotDelegate>

@property (strong, nonatomic) Snapshot *snapshot;

@end
