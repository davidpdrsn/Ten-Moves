//
//  SnapshotsTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "SnapshotsTableViewController.h"
#import "ArrayDataSource.h"

@interface SnapshotsTableViewController ()

@property (strong, nonatomic) ArrayDataSource *dataSource;

@end

@implementation SnapshotsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSnapshot)];
    
    self.dataSource = [self createDataSource];
    
    self.tableView.delegate = self.dataSource;
    self.tableView.dataSource = self.dataSource;
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

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Snapshot" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"move = %@", self.move];
    [fetchRequest setPredicate:predicate];
    return fetchRequest;
}

- (ArrayDataSource *)createDataSource {
    ArrayDataSource *data = [[ArrayDataSource alloc] initWithItems:[self fetchRequest]
                                              managedObjectContext:self.managedObjectContext
                                                    cellIdentifier:@"Snapshot"
                                                configureCellBlock:^UITableViewCell *(UITableViewCell *cell, Snapshot *snapshot) {
                                                    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                                                    [formatter setDateStyle:NSDateFormatterMediumStyle];
                                                    cell.textLabel.text = [formatter stringFromDate:snapshot.createdAt];
                                                    
                                                    return cell;
                                                }];
    return data;
}

@end
