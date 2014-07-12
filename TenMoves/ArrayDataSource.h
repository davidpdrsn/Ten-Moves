//
//  ArrayDataSource.h
//  TenMoves
//
//  Created by David Pedersen on 12/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ArrayDataSource : NSObject <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate>

- (instancetype)initWithItems:(NSFetchRequest *)fetchRequest
         managedObjectContext:(NSManagedObjectContext *)managedObjectContext
               cellIdentifier:(NSString *)cellIdentifier
           configureCellBlock:(UITableViewCell* (^)(UITableViewCell* cell, id item))configureCellBlock;

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

@end
