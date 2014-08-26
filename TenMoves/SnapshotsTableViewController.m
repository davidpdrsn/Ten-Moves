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
#import "UITableViewCell+HelperMethods.h"
#import "ALAssetsLibrary+HelperMethods.h"
#import "SnapshotTableViewCell.h"
#import "VideoPreview.h"
#import "Snapshot.h"
#import "Move.h"
#import "AddSnapshotTableViewController.h"
#import "ShowSnapshotViewController.h"
#import "SnapshotVideo.h"
#import "SnapshotImage.h"
@import MediaPlayer;
@import AssetsLibrary;
@import AVFoundation;

@interface SnapshotsTableViewController ()

@property (strong, nonatomic) ArrayDataSource *dataSource;
@property (strong, readonly, nonatomic) NSDateFormatter *formatter;

@end

@implementation SnapshotsTableViewController

@synthesize formatter = __formatter;

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.view.tintColor = self.view.tintColor;
    
    self.dataSource = [self createDataSource];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self.dataSource;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
    // The selected cell doesn't have the progress cirlce showing when swiping back
    // this code fixes that
    for (SnapshotTableViewCell *cell in self.tableView.visibleCells) {
        [cell setProgressIndicatorBackground];
    }
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddSnapshot"]) {
        UINavigationController *nav = (UINavigationController *)segue.destinationViewController;
        AddSnapshotTableViewController *add = (AddSnapshotTableViewController *)nav.topViewController;
        Snapshot *snapshot = [Snapshot newManagedObject];
        [self.move addSnapshotsObject:snapshot];
        add.currentSnapshot = snapshot;
        add.delegate = self;
    } else if ([segue.identifier isEqualToString:@"showSnapshot"]) {
        Snapshot *snapshot = [self.dataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
        ShowSnapshotViewController *destination = (ShowSnapshotViewController *)segue.destinationViewController;
        destination.snapshot = snapshot;
    }
}

#pragma mark - add snapshot delegate

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
    [self.dataSource reload];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - array datasource

- (ArrayDataSource *)createDataSource {
    ConfigureCellBlock configureCell = ^UITableViewCell *(UITableViewCell *cell, Snapshot *snapshot) {
        SnapshotTableViewCell *snapshotCell = (SnapshotTableViewCell *)cell;
        snapshotCell.tintColor = self.view.tintColor;
        snapshotCell.snapshot = snapshot;
        [snapshotCell.thumbnailImageView setVideoAndImageFromSnapshot:snapshot];
        snapshotCell.thumbnailImageView.delegate = self;
        
        return snapshotCell;
    };
    
    return [[ArrayDataSource alloc] initWithItems:[Snapshot fetchRequestForSnapshotsBelongingToMove:self.move]
                                   cellIdentifier:@"Snapshot"
                               configureCellBlock:configureCell];
}

#pragma mark - image view with snapshot delegate methods

- (void)imageViewWithSnapshot:(VideoPreview *)imageView presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)player {
    [self presentMoviePlayerViewControllerAnimated:player];
}

- (void)imageViewWithSnapshotDismissMoviePlayerViewControllerAnimated:(VideoPreview *)imageView {
    [self dismissMoviePlayerViewControllerAnimated];
}

#pragma mark - misc helper methods

- (NSDateFormatter *)formatter {
    if (__formatter) return __formatter;
    __formatter = [[NSDateFormatter alloc] init];
    [__formatter setDateStyle:NSDateFormatterMediumStyle];
    return  __formatter;
}

@end
