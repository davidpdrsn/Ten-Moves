//
//  SnapshotsTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "SnapshotsTableViewController.h"

@interface SnapshotsTableViewController ()

@end

@implementation SnapshotsTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSnapshot)];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error - %@", error);
        abort();
    }
}

- (void)addSnapshot {
    UIStoryboard *storyBoard = [self storyboard];
    AddSnapshotViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"AddSnapshotViewController"];
    Snapshot *snapshot = (Snapshot *) [NSEntityDescription insertNewObjectForEntityForName:@"Snapshot"
                                                        inManagedObjectContext:self.managedObjectContext];
    [self.move addSnapshotsObject:snapshot];
    vc.currentSnapshot = snapshot;
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - table view datasource and delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> secInfo = [self.fetchedResultsController sections][section];
    return [secInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Snapshot";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    Snapshot *snapshot = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    cell.textLabel.text = [formatter stringFromDate:snapshot.createdAt];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Snapshot *snapshotToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [self.managedObjectContext deleteObject:snapshotToDelete];
        
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error %@", error);
        }
    }
}

#pragma mark - Fetched results controller section

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Snapshot" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"move = %@", self.move];
    [fetchRequest setPredicate:predicate];
    
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    UITableView *table = self.tableView;
    
    switch (type) {
        case NSFetchedResultsChangeInsert:
            [table insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeDelete:
            [table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case NSFetchedResultsChangeUpdate: {
            Snapshot *changedSnapshot = [self.fetchedResultsController objectAtIndexPath:indexPath];
            UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            cell.textLabel.text = [formatter stringFromDate:changedSnapshot.createdAt];
            [cell setNeedsLayout];
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [table insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

#pragma mark - add snapshot delegate

- (void)addSnapshotViewControllerDidSave {
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Error saving - %@", error);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addSnapshotViewControllerDidCancel:(Snapshot *)snapshotToDelete {
    [self.move removeSnapshotsObject:snapshotToDelete];
    [self.managedObjectContext deleteObject:snapshotToDelete];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
