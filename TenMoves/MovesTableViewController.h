//
//  MovesTableViewController.h
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMoveViewController.h"
#import "ArrayDataSource.h"

@interface MovesTableViewController : UITableViewController <AddMoveViewControllerDelegate, ArrayDataSourceDelegate>

@end
