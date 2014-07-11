//
//  MovesTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "MovesTableViewController.h"
#import "Move.h"
#import "MoveTableViewCell.h"
#import "SnapshotsTableViewController.h"

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
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.tableView reloadData];
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
    static NSString *identifier = @"Move";
    MoveTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    Move *move = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.nameLabel.text = move.name;
    cell.countLabel.text = [NSString stringWithFormat:@"%i", (int)move.snapshots.count];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    cell.detailTextLabel.text = [formatter stringFromDate:move.createdAt];
    
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

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSnapshots"]) {
        SnapshotsTableViewController *destination = (SnapshotsTableViewController *) segue.destinationViewController;
        destination.move = [self.fetchedResultsController objectAtIndexPath:[self.tableView indexPathForSelectedRow]];
        destination.managedObjectContext = self.managedObjectContext;
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
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt"
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
            MoveTableViewCell *cell = (MoveTableViewCell *) [table cellForRowAtIndexPath:indexPath];
            cell.nameLabel.text = changedMove.name;
            [cell setNeedsLayout];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing name" message:@"Are you sure the move has a name?" delegate:nil cancelButtonTitle:@"I'll look into it" otherButtonTitles:nil];
        [alert show];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)addCourseViewControllerDidCancel:(Move *)moveToDelete {
    [self.managedObjectContext deleteObject:moveToDelete];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Empty table view data

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"Zero Moves";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"It seems you have not added any moves yet. Tap the plus button to get started.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


@end
