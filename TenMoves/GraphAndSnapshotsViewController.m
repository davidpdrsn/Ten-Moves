//
//  GraphAndSnapshotsViewController.m
//  TenMoves
//
//  Created by David Pedersen on 26/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "GraphAndSnapshotsViewController.h"
#import "SnapshotsTableViewController.h"
#import "Move.h"
#import "GraphViewController.h"
#import "Snapshot.h"
#import "AddSnapshotTableViewController.h"
#import "AddSnapshotTableViewControllerDelegate.h"
#import "Repository.h"
#import "UIView+Autolayout.h"

@interface GraphAndSnapshotsViewController () <AddSnapshotTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *graphContainerView;
@property (weak, nonatomic) IBOutlet UIView *tableContainerView;

@end

@implementation GraphAndSnapshotsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = self.move.name;
}

- (BOOL)smallScreen {
    return [UIScreen mainScreen].bounds.size.height < 667.0;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"EmbedTable"]) {
        SnapshotsTableViewController *destination =
            (SnapshotsTableViewController *)segue.destinationViewController;
        destination.move = self.move;

    } else if ([segue.identifier isEqualToString:@"EmbedGraph"]) {
        GraphViewController *graphViewController =
            (GraphViewController *)segue.destinationViewController;
        graphViewController.move = self.move;

    } else if ([segue.identifier isEqualToString:@"AddSnapshot"]) {
        UINavigationController *nav = (UINavigationController *)segue.destinationViewController;
        AddSnapshotTableViewController *add =
            (AddSnapshotTableViewController *)nav.topViewController;
        Snapshot *snapshot = [Snapshot newManagedObject];
        [self.move addSnapshotsObject:snapshot];
        snapshot.move = self.move;
        add.currentSnapshot = snapshot;
        add.delegate = self;
    }
}

- (void)addSnapshotTableViewControllerDidSave {
    [Repository saveWithCompletionHandler:^(NSError *error) {
        if (error) {
            [[[UIAlertView alloc] initWithTitle:@"Video missing"
                                        message:@"Snapshots have to contain a video"
                                       delegate:nil
                              cancelButtonTitle:@"Okay, sorry"
                              otherButtonTitles:nil] show];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)addSnapshotTableViewControllerDidCancel:(Snapshot *)snapshotToDelete {
    [self.move removeSnapshotsObject:snapshotToDelete];
    [Repository deleteObject:snapshotToDelete];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
