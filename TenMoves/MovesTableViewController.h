//
//  MovesTableViewController.h
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ArrayDataSourceDelegate.h"
#import "AddMoveViewControllerDelegate.h"

@class AddMoveViewController;
@class ArrayDataSource;

@interface MovesTableViewController : UITableViewController <AddMoveViewControllerDelegate, ArrayDataSourceDelegate>

@end
