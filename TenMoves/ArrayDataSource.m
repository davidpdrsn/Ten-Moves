//
//  ArrayDataSource.m
//  TenMoves
//
//  Created by David Pedersen on 12/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ArrayDataSource.h"
#import "Repository.h"

@interface ArrayDataSource ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) ConfigureCellBlock configureCellBlock;
@property (strong, nonatomic) UITableView *table;

@end

@implementation ArrayDataSource

- (void)reload {
    NSError *error;
    if (![_fetchedResultsController performFetch:&error]) {
        NSLog(@"Error - %@", [error userInfo]);
    }
    
    [self.table reloadData];
}

- (instancetype)initWithItems:(NSFetchRequest *)fetchRequest
               cellIdentifier:(NSString *)cellIdentifier
           configureCellBlock:(ConfigureCellBlock)configureCellBlock {
    self = [super init];
    if (self) {
        _cellIdentifier = cellIdentifier;
        _configureCellBlock = configureCellBlock;
        
        _fetchedResultsController =
            [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                managedObjectContext:[Repository managedObjectContext]
                                                  sectionNameKeyPath:nil
                                                           cacheName:nil];
        
        _fetchedResultsController.delegate = self;
        
        [self reload];
    }
    return self;
}

- (NSUInteger)totalNumberOfObjects {
    return self.fetchedResultsController.fetchedObjects.count;
}

- (NSArray *)objects {
    return self.fetchedResultsController.fetchedObjects;
}

#pragma mark - table view data source methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (!self.table) {
        self.table = tableView;
    }
    
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id<NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    self.configureCellBlock(cell, [self itemAtIndexPath:indexPath]);
    return cell;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id itemToDelete = [self itemAtIndexPath:indexPath];
        [Repository deleteObject:itemToDelete];
        
        [Repository saveWithCompletionHandler:^(NSError *error) {
            if (error) {
                NSLog(@"Error %@", error);
            }
        }];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return [self.delegate arrayDataSource:self
                        textForFooterView:self.fetchedResultsController.fetchedObjects];
}

#pragma mark - fetched results controller delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.table beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    NSIndexSet *set = [[NSIndexSet alloc] initWithIndex:0];
    [self.table reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [self.delegate arrayDataSourceDidChangeData:self];
    
    [self.table endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.table insertRowsAtIndexPaths:@[newIndexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.table deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            id changedItem = [self itemAtIndexPath:indexPath];
            UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
            self.configureCellBlock(cell, changedItem);
            [cell setNeedsLayout];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [self.table deleteRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.table insertRowsAtIndexPaths:@[newIndexPath]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

#pragma mark - empty table view

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.emptyTableViewHeaderText) {
        NSString *text = self.emptyTableViewHeaderText;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                     NSForegroundColorAttributeName: [UIColor lightGrayColor]};
        
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    } else {
        return nil;
    }
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    if (self.emptyTableViewText) {
        NSString *text = self.emptyTableViewText;
        
        NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        paragraph.alignment = NSTextAlignmentCenter;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                     NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                     NSParagraphStyleAttributeName: paragraph};
        
        return [[NSAttributedString alloc] initWithString:text attributes:attributes];
    } else {
        return nil;
    }
}

@end
