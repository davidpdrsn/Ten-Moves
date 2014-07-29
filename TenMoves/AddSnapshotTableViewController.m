//
//  AddSnapshotViewController.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
@import AssetsLibrary;
@import MediaPlayer;

#import "AddSnapshotTableViewController.h"
#import "Snapshot.h"
#import "Constants.h"
#import "ProgressPickerButton.h"
#import "ImageViewWithSnapshot.h"
#import "ALAssetsLibrary+HelperMethods.h"
#import "Move.h"

@interface AddSnapshotTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *progressCell;
@property (weak, nonatomic) IBOutlet UIButton *pickVideoButton;

@property (weak, nonatomic) IBOutlet ProgressPickerButton *improvedProgressView;
@property (weak, nonatomic) IBOutlet ProgressPickerButton *sameProgressView;
@property (weak, nonatomic) IBOutlet ProgressPickerButton *regressionProgressView;

@end

@implementation AddSnapshotTableViewController

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.improvedProgressView setProgressType:SnapshotProgressImproved];
    [self.improvedProgressView setLabelText:@"Better"];
    [self.improvedProgressView setShowBorder:YES];
    
    [self.sameProgressView setProgressType:SnapshotProgressSame];
    [self.sameProgressView setLabelText:@"Same"];
    [self.sameProgressView setShowBorder:YES];
    
    [self.regressionProgressView setProgressType:SnapshotProgressRegressed];
    [self.regressionProgressView setLabelText:@"Worse"];
    [self.regressionProgressView setShowBorder:NO];
    
    if ([self snapshotIsBaseline]) {
        for (ProgressPickerButton *progressPicker in @[self.improvedProgressView,
                                                       self.sameProgressView,
                                                       self.regressionProgressView]) {
            progressPicker.enabled = NO;
        }
        
        self.progressCell.userInteractionEnabled = NO;
    } else {
        [self.currentSnapshot setProgressTypeRaw:SnapshotProgressImproved];
    }
    
    [self updateActiveProgressPicker];
}

#pragma mark - IBActions

- (IBAction)improvedTapped:(ProgressPickerButton *)sender {
    [self.currentSnapshot setProgressTypeRaw:sender.type];
    [self updateActiveProgressPicker];
}

- (IBAction)sameTapped:(ProgressPickerButton *)sender {
    [self.currentSnapshot setProgressTypeRaw:sender.type];
    [self updateActiveProgressPicker];
}

- (IBAction)regressedTapped:(ProgressPickerButton *)sender {
    [self.currentSnapshot setProgressTypeRaw:sender.type];
    [self updateActiveProgressPicker];
}

- (IBAction)cancel:(id)sender {
    [self.delegate addSnapshotTableViewControllerDidCancel:self.currentSnapshot];
}

- (IBAction)done:(id)sender {
    [self.delegate addSnapshotTableViewControllerDidSave];
}

- (IBAction)pickPhoto:(id)sender {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Take Video", @"Choose Existing", nil];
    [sheet showInView:self.view];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self startMediaBrowserFromViewController:self usingDelegate:self type:UIImagePickerControllerSourceTypeCamera];
            break;
            
        case 1:
            [self startMediaBrowserFromViewController:self usingDelegate:self type:UIImagePickerControllerSourceTypePhotoLibrary];
            break;
            
        default:
            break;
    }
}

#pragma mark - table view

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1 && [self snapshotIsBaseline]) {
        return @"The first snapshot is considered the baseline, so you can't rate it. You will be able to when you add the next snapshot.";
    }
    
    return nil;
}

#pragma mark - picking video

- (void)startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate
                                       type:(UIImagePickerControllerSourceType)type {
    if (([UIImagePickerController isSourceTypeAvailable: type] == NO) || (delegate == nil) || (controller == nil)) {
        return;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = type;
    mediaUI.view.tintColor = self.view.tintColor;
    mediaUI.mediaTypes = @[(NSString *)kUTTypeMovie];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    [controller presentViewController:mediaUI animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
    
    [self.currentSnapshot saveVideoAtFileUrl:mediaUrl completionBlock:^{
        [self.pickVideoButton setTitle:@"Add different video" forState:UIControlStateNormal];
        [self showThumbnailOfVideo];
    } failureBlock:^(NSError *error) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed copying video" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)showThumbnailOfVideo {
    int offset = 5;
    CGFloat size = self.pickVideoButton.superview.frame.size.height-offset*2;
    ImageViewWithSnapshot *thumbnail = [[ImageViewWithSnapshot alloc] initWithFrame:CGRectMake(offset, offset, size, size)];
    
    thumbnail.snapshot = self.currentSnapshot;
    thumbnail.delegate = self;
    
    [self.pickVideoButton.superview addSubview:thumbnail];
    [thumbnail awakeFromNib];
}

#pragma mark - ImageViewSnapshot delegate methods

- (void)imageViewWithSnapshot:(ImageViewWithSnapshot *)imageView presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)player {
    [self presentMoviePlayerViewControllerAnimated:player];
}

- (void)imageViewWithSnapshotDismissMoviePlayerViewControllerAnimated:(ImageViewWithSnapshot *)imageView {
    [self dismissMoviePlayerViewControllerAnimated];
}

#pragma mark - misc helper methods

- (BOOL)snapshotIsBaseline {
    return [self numberOfSnapshotsForMove] == 1;
}

- (NSUInteger)numberOfSnapshotsForMove {
    return [[self.currentSnapshot move] snapshots].count;
}

- (void)updateActiveProgressPicker {
    for (ProgressPickerButton *progressView in @[self.improvedProgressView, self.sameProgressView, self.regressionProgressView]) {
        BOOL shouldBeActive = self.currentSnapshot.progressTypeRaw == progressView.type;
        [progressView setActive:shouldBeActive];
    }
}

@end
