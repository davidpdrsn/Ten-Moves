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
@import AVFoundation;

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

@property (strong, nonatomic) UIView *loadingView;

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

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    for (ProgressPickerButton *progress in @[self.sameProgressView, self.improvedProgressView, self.regressionProgressView]) {
        [progress setEnabled:NO];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    for (ProgressPickerButton *progress in @[self.sameProgressView, self.improvedProgressView, self.regressionProgressView]) {
        [progress setEnabled:YES];
    }
}

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

- (void)showVideoCopyAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed copying video" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (void)addVideoToSnapshotAtUrl:(NSURL *)mediaUrl {
    [self.currentSnapshot saveVideoAtFileUrl:mediaUrl completionBlock:^{
        [self.pickVideoButton setTitle:@"Add different video" forState:UIControlStateNormal];
        [self showThumbnailOfVideo];
    } failureBlock:^(NSError *error) {
        [self showVideoCopyAlert];
    }];
}

- (void)saveEditedVideoAtUrl:(NSURL *)mediaUrl start:(NSNumber *)start end:(NSNumber *)end {
    int startMilliseconds = ([start doubleValue] * 1000);
    int endMilliseconds = ([end doubleValue] * 1000);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *outputURL = [documentsDirectory stringByAppendingPathComponent:@"output"] ;
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"];
    [manager removeItemAtPath:outputURL error:nil];
    
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:mediaUrl options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetHighestQuality];
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMake(startMilliseconds, 1000), CMTimeMake(endMilliseconds - startMilliseconds, 1000));
    exportSession.timeRange = timeRange;
    
    [self startLoading];
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted:
                [self endLoading];
                [self addVideoToSnapshotAtUrl:exportSession.outputURL];
                break;
            default:
                [self endLoading];
                [self showVideoCopyAlert];
                break;
        }
    }];
}

- (void)startLoading {
    self.navigationController.view.userInteractionEnabled = NO;
    
    CGRect frame = CGRectMake(0, 0, 120, 120);
    self.loadingView = [[UIView alloc] initWithFrame:frame];
    self.loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.75];
    self.loadingView.layer.cornerRadius = 5;
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.hidden = NO;
    
    [spinner startAnimating];
    [self addViewCentered:spinner inSuperView:self.view];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Importing";
    label.font = [UIFont boldSystemFontOfSize:label.font.pointSize];
    label.textColor = [UIColor whiteColor];
    [label sizeToFit];
    
    [self addViewCentered:label inSuperView:self.loadingView];
    
    [self addViewCentered:spinner inSuperView:self.loadingView];
    [self addViewCentered:self.loadingView inSuperView:self.navigationController.view];
    
    [self adjustCenterX:0 y:35 inView:label];
    [self adjustCenterX:0 y:-5 inView:spinner];
    double delta = -7;
    [self adjustCenterX:0 y:delta inView:label];
    [self adjustCenterX:0 y:delta inView:spinner];
    [self adjustCenterX:0 y:-13 inView:self.loadingView];
}

- (void)adjustCenterX:(double)deltaX y:(double)deltaY inView:(UIView *)view {
    view.center = CGPointMake(view.center.x+deltaX, view.center.y+deltaY);
}

- (void)addViewCentered:(UIView *)view inSuperView:(UIView *)superView {
    [superView addSubview:view];
    
    CGRect oldFrame = view.bounds;
    CGRect superFrame = superView.bounds;
    
    view.frame = CGRectMake(superFrame.size.width/2 - oldFrame.size.width/2,
                            superFrame.size.height/2 - oldFrame.size.height/2,
                            oldFrame.size.width, oldFrame.size.height);
}

- (void)endLoading {
    [UIView animateWithDuration:.13 animations:^{
        self.loadingView.frame = CGRectMake(self.loadingView.frame.origin.x,
                                            self.loadingView.frame.origin.y - 20,
                                            self.loadingView.frame.size.width,
                                            self.loadingView.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.4 animations:^{
            self.loadingView.frame = CGRectMake(self.loadingView.frame.origin.x,
                                                self.loadingView.frame.origin.y + self.view.frame.size.height*.75,
                                                self.loadingView.frame.size.width,
                                                self.loadingView.frame.size.height);
        } completion:^(BOOL finished) {
            [self.loadingView removeFromSuperview];
            self.navigationController.view.userInteractionEnabled = YES;
        }];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
    
    BOOL videoWasEdited = info[@"_UIImagePickerControllerVideoEditingStart"] && info[@"_UIImagePickerControllerVideoEditingEnd"];
    if (videoWasEdited) {
        NSNumber *start = [info objectForKey:@"_UIImagePickerControllerVideoEditingStart"];
        NSNumber *end = [info objectForKey:@"_UIImagePickerControllerVideoEditingEnd"];
        
        [self saveEditedVideoAtUrl:mediaUrl start:start end:end];
    } else {
        [self addVideoToSnapshotAtUrl:mediaUrl];
    }
    
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
