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
#import "VideoEditor.h"
#import "LPBlockActionSheet.h"

@interface AddSnapshotTableViewController ()

@property (strong, nonatomic) ImageViewWithSnapshot *thumbnail;
@property (assign, nonatomic) BOOL resizedButton;

@property (weak, nonatomic) IBOutlet UITableViewCell *progressCell;
@property (weak, nonatomic) IBOutlet UIButton *pickVideoButton;

@property (weak, nonatomic) IBOutlet ProgressPickerButton *improvedProgressView;
@property (weak, nonatomic) IBOutlet ProgressPickerButton *sameProgressView;
@property (weak, nonatomic) IBOutlet ProgressPickerButton *regressionProgressView;

@property (assign, nonatomic) SnapshotProgress selectedProgress;
@property (strong, nonatomic) NSURL *urlOfSelectedVideo;

@property (weak, nonatomic) IBOutlet JTSTextView *textView;
@property (assign, nonatomic) CGFloat initialTextViewHeight;

@property (strong, nonatomic) LPBlockActionSheet *sheet;

@end

@implementation AddSnapshotTableViewController

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.improvedProgressView setProgressType:SnapshotProgressImproved];
    [self.improvedProgressView setLabelText:[Snapshot textForProgressType:SnapshotProgressImproved]];
    [self.improvedProgressView setShowBorder:YES];
    
    [self.sameProgressView setProgressType:SnapshotProgressSame];
    [self.sameProgressView setLabelText:[Snapshot textForProgressType:SnapshotProgressSame]];
    [self.sameProgressView setShowBorder:YES];
    
    [self.regressionProgressView setProgressType:SnapshotProgressRegressed];
    [self.regressionProgressView setLabelText:[Snapshot textForProgressType:SnapshotProgressRegressed]];
    [self.regressionProgressView setShowBorder:NO];
    
    if ([self snapshotIsBaseline]) {
        for (ProgressPickerButton *progressPicker in @[self.improvedProgressView,
                                                       self.sameProgressView,
                                                       self.regressionProgressView]) {
            progressPicker.enabled = NO;
        }
        
        self.progressCell.userInteractionEnabled = NO;
    } else {
        self.selectedProgress = (self.currentSnapshot.progressTypeRaw == SnapshotProgressBaseline) ?
                                SnapshotProgressImproved :
                                self.currentSnapshot.progressTypeRaw;
        
        [self updateActiveProgressPicker];
    }
    
    [self updateActiveProgressPicker];
    
    [self configureTextView];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self.tableView addGestureRecognizer:tapper];
    
    if (self.currentSnapshot.video) {
        [self showThumbnailOfVideoAnimated:NO];
    }
    
    if (self.editingSnapshot) {
        self.title = @"Edit snapshot";
    }
}

- (void)endEditing {
    [self.tableView endEditing:YES];
}

#pragma mark - IBActions

// TODO: remove duplication
- (IBAction)improvedTapped:(ProgressPickerButton *)sender {
    self.selectedProgress = sender.type;
    [self updateActiveProgressPicker];
}

- (IBAction)sameTapped:(ProgressPickerButton *)sender {
    self.selectedProgress = sender.type;
    [self updateActiveProgressPicker];
}

- (IBAction)regressedTapped:(ProgressPickerButton *)sender {
    self.selectedProgress = sender.type;
    [self updateActiveProgressPicker];
}

- (IBAction)cancel:(id)sender {
    if (self.editingSnapshot) {
        [self.delegate dismissAddSnapshotTableViewController];
    } else {
        [self.delegate addSnapshotTableViewControllerDidCancel:self.currentSnapshot];
    }
}

- (IBAction)done:(id)sender {
    self.currentSnapshot.notes = self.textView.text;
    [self.currentSnapshot setProgressTypeRaw:self.selectedProgress];
    
    [self.delegate addSnapshotTableViewControllerDidSave];
}

- (IBAction)pickPhoto:(id)sender {
    if (!self.sheet) {
        [self configureActionSheet];
    }
    
    [self.sheet showInView:self.view];
}

- (void)configureActionSheet {
    self.sheet = [[LPBlockActionSheet alloc] init];
    
    __weak AddSnapshotTableViewController *_self = self;
    
    [self.sheet setCancelButtonTitle:@"Cancel" block:nil];
    
    [self.sheet addButtonWithTitle:@"Take Video" block:^{
        [_self startMediaBrowserFromViewController:_self usingDelegate:_self type:UIImagePickerControllerSourceTypeCamera];
    }];
    
    [self.sheet addButtonWithTitle:@"Choose Existing" block:^{
        [_self startMediaBrowserFromViewController:_self usingDelegate:_self type:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    NSArray *progressViews = @[_self.sameProgressView, _self.improvedProgressView, _self.regressionProgressView];
    
    self.sheet.willPresentCallBack = ^{
        for (ProgressPickerButton *progress in progressViews) {
            [progress setEnabled:NO];
        }
    };
    
    self.sheet.willDismissCallBack = ^{
        for (ProgressPickerButton *progress in progressViews) {
            if (![_self snapshotIsBaseline]) {
                [progress setEnabled:YES];
            }
        }
    };
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
        [self showThumbnailOfVideoAnimated:YES];
    } failureBlock:^(NSError *error) {
        [self showVideoCopyAlert];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
    
    BOOL videoWasEdited = info[@"_UIImagePickerControllerVideoEditingStart"] && info[@"_UIImagePickerControllerVideoEditingEnd"];
    if (videoWasEdited) {
        NSNumber *start = [info objectForKey:@"_UIImagePickerControllerVideoEditingStart"];
        NSNumber *end = [info objectForKey:@"_UIImagePickerControllerVideoEditingEnd"];
        
        VideoEditor *editor = [[VideoEditor alloc] init];
        [editor trimVideoAtUrl:mediaUrl start:start end:end completionBlock:^(NSURL *urlOfTrimmedVideo) {
            [self addVideoToSnapshotAtUrl:urlOfTrimmedVideo];
//            self.urlOfSelectedVideo = urlOfTrimmedVideo;
        } failureBlock:^(NSError *error) {
            [self showVideoCopyAlert];
        }];
    } else {
        [self addVideoToSnapshotAtUrl:mediaUrl];
//        self.urlOfSelectedVideo = mediaUrl;
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)resizeAddVideoButton:(int)offset size:(CGFloat)size {
    CGRect currentFrame = self.pickVideoButton.frame;
    CGFloat delta = size + offset*2;
    self.pickVideoButton.frame = CGRectMake(currentFrame.origin.x + delta,
                                            currentFrame.origin.y,
                                            currentFrame.size.width - delta,
                                            currentFrame.size.height);
}

- (void)showThumbnailOfVideoAnimated:(BOOL)animated {
    int offset = 5;
    CGFloat size = self.pickVideoButton.superview.frame.size.height-offset*2;
    
    CGRect frame = CGRectMake(offset, offset, size, size);
    
    if (self.thumbnail) {
        [self.thumbnail removeFromSuperview];
    }
    
    self.thumbnail = [[ImageViewWithSnapshot alloc] initWithFrame:frame];
    self.thumbnail.tintColor = self.view.tintColor;
    
    self.thumbnail.snapshot = self.currentSnapshot;
    self.thumbnail.delegate = self;
    
    [self.pickVideoButton.superview addSubview:self.thumbnail];
    
    [self.thumbnail awakeFromNib];
    
    if (!self.resizedButton) {
        self.resizedButton = YES;
        
        CGPoint destination = self.thumbnail.center;
        self.thumbnail.center = CGPointMake(self.thumbnail.center.x-(self.thumbnail.frame.size.width+offset), self.thumbnail.center.y);
        
        void (^showThumbnail)() = ^void() {
            self.thumbnail.center = destination;
            [self resizeAddVideoButton:offset size:size];
        };
        
        if (animated) {
            [UIView animateWithDuration:.5
                                  delay:.5
                 usingSpringWithDamping:.5
                  initialSpringVelocity:20
                                options:UIViewAnimationOptionCurveLinear
                             animations:showThumbnail
                             completion:nil];
        } else {
            showThumbnail();
        }
    }
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
    return [self.currentSnapshot isBaseline];
}

- (void)updateActiveProgressPicker {
    [self endEditing];
    
    for (ProgressPickerButton *progressView in @[self.improvedProgressView, self.sameProgressView, self.regressionProgressView]) {
        BOOL shouldBeActive = self.selectedProgress == progressView.type;
        [progressView setActive:shouldBeActive];
    }
}

#pragma mark - text view methods

- (void)configureTextView {
    self.textView.textViewDelegate = self;
    self.textView.automaticallyAdjustsContentInsetForKeyboard = NO;
    self.initialTextViewHeight = self.textView.frame.size.height;
    self.textView.textContainerInset = UIEdgeInsetsMake(7, 7, 7, 7);
    
    if (self.currentSnapshot.notes) {
        self.textView.text = self.currentSnapshot.notes;
        [self textViewDidChange:self.textView];
    }
}

- (void)textViewDidBeginEditing:(JTSTextView *)textView {
    if ([textView.text isEqualToString:@" "]) {
        textView.text = @"";
    }
}

- (void)textViewDidChange:(JTSTextView *)textView {
    CGRect frame = textView.frame;
    
    if (textView.contentSize.height < self.initialTextViewHeight) {
        frame.size.height = self.initialTextViewHeight;
    } else {
        frame.size.height = textView.contentSize.height;
    }
    
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    self.textView.frame = frame;
    
    [self tableViewScrollToBottomAnimated:YES];
}

- (void)tableViewScrollToBottomAnimated:(BOOL)animated {
    NSInteger numberOfRows = [self.tableView numberOfRowsInSection:2];
    if (numberOfRows) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:2] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2) {
        CGFloat height = self.textView.contentSize.height;
        
        if (height < self.initialTextViewHeight) {
            return self.initialTextViewHeight;
        } else {
            return height;
        }
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

@end
