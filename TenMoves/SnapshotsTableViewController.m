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
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addSnapshot)];
    
    self.dataSource = [self createDataSource];
    
    self.tableView.delegate = self;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Snapshot *snapshot = [self.dataSource itemAtIndexPath:indexPath];

    [ALAssetsLibrary assetForURL:[snapshot videoUrl] resultBlock:^(ALAsset *asset) {
        self.player = [[MPMoviePlayerController alloc] initWithContentURL:[snapshot videoUrl]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerWillExitFullscreenNotification
                                                   object:nil];
        
        [self.view addSubview:self.player.view];
        [self.player.view setFrame:self.view.frame];
        [self.player setFullscreen:YES animated:YES];
        [self.player play];
    } failureBlock:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video not found" message:@"..." delegate:nil cancelButtonTitle:@"Ups" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    [self.player.view removeFromSuperview];
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
    ConfigureCellBlock configureCell = ^UITableViewCell *(UITableViewCell *cell, Snapshot *snapshot) {
        SnapshotTableViewCell *snapshotCell = (SnapshotTableViewCell *)cell;
        snapshotCell.dateLabel.text = [self.formatter stringFromDate:snapshot.createdAt];
        
        [ALAssetsLibrary assetForURL:snapshot.videoUrl resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            snapshotCell.thumbnailImageView.image = image;
        } failureBlock:^(NSError *error) {
            NSLog(@"image not found...");
        }];
        
        return snapshotCell;
    };
    
    return [[ArrayDataSource alloc] initWithItems:[Snapshot fetchRequestForMove:self.move]
                                   cellIdentifier:@"Snapshot"
                               configureCellBlock:configureCell];
}

- (NSDateFormatter *)formatter {
    if (__formatter) return __formatter;
    __formatter = [[NSDateFormatter alloc] init];
    [__formatter setDateStyle:NSDateFormatterMediumStyle];
    return  __formatter;
}

@end
