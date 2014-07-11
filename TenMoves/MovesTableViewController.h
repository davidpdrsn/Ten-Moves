//
//  MovesTableViewController.h
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMoveViewController.h"
#import "UIScrollView+EmptyDataSet.h"

@interface MovesTableViewController : UITableViewController <AddMoveViewControllerDelegate, NSFetchedResultsControllerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end
