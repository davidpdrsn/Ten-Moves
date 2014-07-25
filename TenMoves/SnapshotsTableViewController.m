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
#import "ImageViewWithSnapshot.h"
#import "Snapshot.h"
#import "Move.h"
#import "AddSnapshotTableViewController.h"
@import MediaPlayer;
@import AssetsLibrary;
@import AVFoundation;

@interface SnapshotsTableViewController ()

@property (strong, nonatomic) ArrayDataSource *dataSource;
@property (strong, nonatomic) MPMoviePlayerController *player;
@property (strong, readonly, nonatomic) NSDateFormatter *formatter;

@end

@implementation SnapshotsTableViewController

@synthesize formatter = __formatter;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.view.tintColor = self.view.tintColor;
    
    self.dataSource = [self createDataSource];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self.dataSource;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    [self.player.view removeFromSuperview];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"AddSnapshot"]) {
        UINavigationController *nav = (UINavigationController *)segue.destinationViewController;
        AddSnapshotTableViewController *add = (AddSnapshotTableViewController *)nav.topViewController;
        Snapshot *snapshot = [Snapshot newManagedObject];
        [self.move addSnapshotsObject:snapshot];
        add.currentSnapshot = snapshot;
        add.delegate = self;
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
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (ArrayDataSource *)createDataSource {
    ConfigureCellBlock configureCell = ^UITableViewCell *(UITableViewCell *cell, Snapshot *snapshot) {
        SnapshotTableViewCell *snapshotCell = (SnapshotTableViewCell *)cell;
        snapshotCell.tintColor = self.view.tintColor;
        snapshotCell.snapshot = snapshot;
        
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
        [snapshotCell.thumbnailImageView addGestureRecognizer:tapped];
        snapshotCell.thumbnailImageView.snapshot = snapshot;
        snapshotCell.thumbnailImageView.userInteractionEnabled = YES;
        
        return snapshotCell;
    };
    
    return [[ArrayDataSource alloc] initWithItems:[Snapshot fetchRequestForMove:self.move]
                                   cellIdentifier:@"Snapshot"
                               configureCellBlock:configureCell];
}

- (void)imageTapped:(UIGestureRecognizer *)gesture {
    ImageViewWithSnapshot *imageView = (ImageViewWithSnapshot *)gesture.view;
    Snapshot *snapshot = imageView.snapshot;
    
//    [ALAssetsLibrary assetForURL:[snapshot videoUrl] resultBlock:^(ALAsset *asset) {
        self.player = [[MPMoviePlayerController alloc] initWithContentURL:[snapshot videoUrl]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerWillExitFullscreenNotification
                                                   object:nil];
        
        [self.view addSubview:self.player.view];
        [self.player.view setFrame:self.view.frame];
        [self.player setFullscreen:YES animated:YES];
        [self.player play];
//    } failureBlock:^(NSError *error) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video not found" message:@"..." delegate:nil cancelButtonTitle:@"Ups" otherButtonTitles:nil];
//        [alert show];
//    }];
}

- (NSDateFormatter *)formatter {
    if (__formatter) return __formatter;
    __formatter = [[NSDateFormatter alloc] init];
    [__formatter setDateStyle:NSDateFormatterMediumStyle];
    return  __formatter;
}

@end
