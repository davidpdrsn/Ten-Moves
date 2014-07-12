//
//  ArrayDataSource.m
//  TenMoves
//
//  Created by David Pedersen on 12/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ArrayDataSource.h"

@interface ArrayDataSource ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSString *cellIdentifier;
@property (strong, nonatomic) UITableViewCell* (^configureCellBlock)(UITableViewCell *cell, id item);
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITableView *table;

@end

@implementation ArrayDataSource

- (instancetype)initWithItems:(NSFetchRequest *)fetchRequest
         managedObjectContext:(NSManagedObjectContext *)managedObjectContext
               cellIdentifier:(NSString *)cellIdentifier
           configureCellBlock:(UITableViewCell* (^)(UITableViewCell* cell, id item))configureCellBlock {
    self = [super init];
    if (self) {
        _cellIdentifier = cellIdentifier;
        _configureCellBlock = configureCellBlock;
        _managedObjectContext = managedObjectContext;
        
        _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        
        _fetchedResultsController.delegate = self;
        
        NSError *error;
        if (![_fetchedResultsController performFetch:&error]) {
            NSLog(@"Error - %@", [error userInfo]);
        }
    }
    return self;
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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier];
    self.configureCellBlock(cell, [self itemAtIndexPath:indexPath]);
    return cell;
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath {
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        id itemToDelete = [self itemAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:itemToDelete];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error %@", error);
        }
    }
}

#pragma mark - fetched results controller delegate methods

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.table beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.table endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [self.table insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            id changedItem = [self itemAtIndexPath:indexPath];
            UITableViewCell *cell = [self.table cellForRowAtIndexPath:indexPath];
            self.configureCellBlock(cell, changedItem);
            [cell setNeedsLayout];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [self.table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self.table insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

@end
