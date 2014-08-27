//
//  ArrayDataSource.h
//  TenMoves
//
//  Created by David Pedersen on 12/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollView+EmptyDataSet.h"
#import "ArrayDataSourceDelegate.h"

typedef UITableViewCell* (^ConfigureCellBlock)(UITableViewCell *cell, id item);

@class ArrayDataSource;

@interface ArrayDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (strong, nonatomic) NSObject<ArrayDataSourceDelegate> *delegate;
@property (strong, nonatomic) NSString *emptyTableViewHeaderText;
@property (strong, nonatomic) NSString *emptyTableViewText;

- (instancetype)initWithItems:(NSFetchRequest *)fetchRequest
               cellIdentifier:(NSString *)cellIdentifier
           configureCellBlock:(UITableViewCell* (^)(UITableViewCell* cell, id item))configureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

- (NSUInteger)totalNumberOfObjects;

- (void)reload;

- (NSArray *)objects;

@end
