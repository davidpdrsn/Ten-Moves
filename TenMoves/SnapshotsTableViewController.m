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
@import MediaPlayer;
@import AssetsLibrary;
@import AVFoundation;

@interface SnapshotsTableViewController ()

@property (strong, nonatomic) ArrayDataSource *dataSource;
@property (strong, nonatomic) MPMoviePlayerController *player;

@end

@implementation SnapshotsTableViewController

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

    ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init];
    
    [lib assetForURL:[snapshot videoUrl] resultBlock:^(ALAsset *asset) {
        _player = [[MPMoviePlayerController alloc] initWithContentURL:[snapshot videoUrl]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerWillExitFullscreenNotification
                                                   object:nil];
        
        [self.view addSubview:_player.view];
        [_player.view setFrame:self.view.frame];
        [_player setFullscreen:YES animated:YES];
        [_player play];
    } failureBlock:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video not found" message:@"..." delegate:nil cancelButtonTitle:@"Ups" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    [_player.view removeFromSuperview];
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
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        
        ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
        
        [library assetForURL:[NSURL URLWithString:snapshot.videoPath] resultBlock:^(ALAsset *asset) {
            UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
            cell.imageView.image = image;
            [cell setNeedsLayout];
        } failureBlock:^(NSError *error) {
        }];
        
        cell.textLabel.text = [formatter stringFromDate:snapshot.createdAt];
        
        return cell;
    };
    
    return [[ArrayDataSource alloc] initWithItems:[Snapshot fetchRequestForMove:self.move]
                                   cellIdentifier:@"Snapshot"
                               configureCellBlock:configureCell];
}

@end
