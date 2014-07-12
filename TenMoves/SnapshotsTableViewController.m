//
//  SnapshotsTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "SnapshotsTableViewController.h"
#import "ArrayDataSource.h"
#import "Repository.h"

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
    Snapshot *snapshot = [Snapshot newManagedObject];
    [self.move addSnapshotsObject:snapshot];
    vc.currentSnapshot = snapshot;
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark - add snapshot delegate

- (void)addSnapshotViewControllerDidSave {
    [Repository saveWithCompletionHandler:^(NSError *error) {
        if (error) {
            NSLog(@"Error saving - %@", error);
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addSnapshotViewControllerDidCancel:(Snapshot *)snapshotToDelete {
    [self.move removeSnapshotsObject:snapshotToDelete];
    [Repository deleteObject:snapshotToDelete];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (ArrayDataSource *)createDataSource {
    ArrayDataSource *data = [[ArrayDataSource alloc] initWithItems:[Snapshot fetchRequestForMove:self.move]
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
