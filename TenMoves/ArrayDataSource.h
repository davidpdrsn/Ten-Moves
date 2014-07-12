//
//  ArrayDataSource.h
//  TenMoves
//
//  Created by David Pedersen on 12/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+EmptyDataSet.h"

@interface ArrayDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (strong, nonatomic) NSString *emptyTableViewHeaderText;
@property (strong, nonatomic) NSString *emptyTableViewText;

@property (strong, nonatomic) NSString* (^textForFooter)(NSArray *items);

- (instancetype)initWithItems:(NSFetchRequest *)fetchRequest
         managedObjectContext:(NSManagedObjectContext *)managedObjectContext
               cellIdentifier:(NSString *)cellIdentifier
           configureCellBlock:(UITableViewCell* (^)(UITableViewCell* cell, id item))configureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
