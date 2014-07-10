//
//  MovesTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "MovesTableViewController.h"
#import "Move.h"

@interface MovesTableViewController ()

@end

@implementation MovesTableViewController

@synthesize fetchedResultsController = _fetchedResultsController;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSError *error;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Error - %@", error);
        abort();
    }
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewMove)];
}

- (void)addNewMove {
    UIStoryboard *storyBoard = [self storyboard];
    AddMoveViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"AddMoveViewController"];
    Move *move = (Move *) [NSEntityDescription insertNewObjectForEntityForName:@"Move"
                                                        inManagedObjectContext:self.managedObjectContext];
    vc.currentMove = move;
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:YES completion:nil];
    

}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> secInfo = [self.fetchedResultsController sections][section];
    return [secInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    Move *move = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.textLabel.text = move.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSManagedObjectContext *context = self.managedObjectContext;
        Move *moveToDelete = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [context deleteObject:moveToDelete];
        
        NSError *error;
        if (![context save:&error]) {
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Move" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name"
                                                                   ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
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
            Move *changedMove = [self.fetchedResultsController objectAtIndexPath:indexPath];
            UITableViewCell *cell = [table cellForRowAtIndexPath:indexPath];
            cell.textLabel.text = changedMove.name;
        }
            break;
            
        case NSFetchedResultsChangeMove:
            [table deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [table insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
    }
}

#pragma mark - add move view controller delegate

- (void)addCourseViewControllerDidSave {
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"There was an error saving the move - %@", error);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addCourseViewControllerDidCancel:(Move *)moveToDelete {
    [self.managedObjectContext deleteObject:moveToDelete];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
