//
//  AddSnapshotViewController.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <MobileCoreServices/UTCoreTypes.h>
@import AssetsLibrary;
@import AVKit;
@import AVFoundation;
#import "AddSnapshotTableViewController.h"
#import "Snapshot.h"
#import "ProgressPickerButton.h"
#import "VideoPreview.h"
#import "ALAssetsLibrary+HelperMethods.h"
#import "Move.h"
#import "VideoEditor.h"
#import "LPBlockActionSheet.h"
#import "SnapshotVideo.h"
#import "UIView+Autolayout.h"
#import "VideoPicker.h"
#import "SnapshotTableViewCell.h"

@interface AddSnapshotTableViewController () <VideoPickerDelegate>

@property (strong, nonatomic) VideoPreview *videoPreview;

@property (strong, nonatomic) NSArray *progressButtons;

@property (weak, nonatomic) IBOutlet UITableViewCell *progressCell;
@property (weak, nonatomic) IBOutlet UIButton *pickVideoButton;
@property (weak, nonatomic) IBOutlet UIView *progressPickerContainer;
@property (weak, nonatomic) IBOutlet VideoPreview *pickedVideoPreview;

@property (assign, nonatomic) SnapshotProgress selectedProgress;
@property (strong, nonatomic) NSURL *urlOfSelectedVideo;

@property (weak, nonatomic) IBOutlet JTSTextView *textView;
@property (assign, nonatomic) CGFloat initialTextViewHeight;

@property (strong, nonatomic) LPBlockActionSheet *sheet;

@property (strong, nonatomic) Snapshot *previousSnapshot;
@property (weak, nonatomic) IBOutlet SnapshotTableViewCell *previousSnapshotCell;

@end

@implementation AddSnapshotTableViewController

#pragma mark - view life cycle


- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupProgressPickers];
    [self setupNotesView];
    [self showCurrentSnapshotIfEditing];
    [self setupPreviousSnapshotCell];
}

#pragma mark - setup views

- (void)setupPreviousSnapshotCell {
    self.previousSnapshot = [self.currentSnapshot previousSnapshot];
    if (self.previousSnapshot == nil) return;

    self.previousSnapshotCell.snapshot = self.previousSnapshot;
    self.previousSnapshotCell.thumbnailImageView.delegate = self;
}

- (void)showCurrentSnapshotIfEditing {
    if (self.editingSnapshot && self.currentSnapshot.video) {
        self.urlOfSelectedVideo = [self.currentSnapshot.video url];
        [self showThumbnailOfVideoAnimated:NO];
        self.title = @"Edit snapshot";
    }
}

- (void)setupActionSheet {
    self.sheet = [[LPBlockActionSheet alloc] init];
    
    typeof(self) __weak weakSelf = self;
    
    [self.sheet setCancelButtonTitle:@"Cancel" block:nil];

    VideoPicker *picker = [[VideoPicker alloc] initWithDelegate:self];
    
    [self.sheet addButtonWithTitle:@"Take Video" block:^{
        [picker startBrowsingForType:UIImagePickerControllerSourceTypeCamera];
    }];
    
    [self.sheet addButtonWithTitle:@"Choose Existing" block:^{
        [picker startBrowsingForType:UIImagePickerControllerSourceTypePhotoLibrary];
    }];
    
    self.sheet.willPresentCallBack = ^{
        weakSelf.videoPreview.enabled = NO;
        weakSelf.previousSnapshotCell.thumbnailImageView.enabled = NO;

        for (ProgressPickerButton *button in weakSelf.progressButtons)
            button.enabled = NO;
    };
    
    self.sheet.didDismissCallBack = ^{
        weakSelf.videoPreview.enabled = YES;
        weakSelf.previousSnapshotCell.thumbnailImageView.enabled = YES;

        if (![weakSelf.currentSnapshot isBaseline]) {
            for (ProgressPickerButton *button in weakSelf.progressButtons)
                button.enabled = YES;
        }
    };
}

- (void)setupProgressPickers {
    self.selectedProgress = self.currentSnapshot.progressTypeRaw;

    ProgressPickerButton *improved = [ProgressPickerButton autolayoutView];
    ProgressPickerButton *same = [ProgressPickerButton autolayoutView];
    ProgressPickerButton *regressed = [ProgressPickerButton autolayoutView];

    // Setup thats different for each button
    improved.type = SnapshotProgressImproved;
    same.type = SnapshotProgressSame;
    regressed.type = SnapshotProgressRegressed;

    self.progressButtons = @[improved, same, regressed];

    improved.hasBorder = YES;
    same.hasBorder = YES;

    // Setup shared for all buttons
    for (ProgressPickerButton *button in self.progressButtons) {
        [self.progressPickerContainer addSubview:button];
        [button constrainFlushTopBottom];
        [button constrainWidthToRatio:.333333];
        NSString *text = [Snapshot textForProgressType:button.type];
        button.label.text = text;
        button.accessibilityLabel = text;
        [button addTarget:self
                   action:@selector(tappedProgressPicker:)
         forControlEvents:UIControlEventTouchUpInside];
    }

    [improved constrainFlushLeft];
    [same constrainCenterHorizontally];
    [regressed constrainFlushRight];

    [self updateActiveProgressPicker];
    
    if ([self.currentSnapshot isBaseline]) {
        self.progressCell.userInteractionEnabled = NO;
        for (ProgressPickerButton *button in self.progressButtons) {
            button.enabled = NO;
        }
    }
}

- (void)updateActiveProgressPicker {
    for (ProgressPickerButton *button in self.progressButtons) {
        [button setActive:(self.selectedProgress == button.type) animated:YES];
    }
}

#pragma mark - Respond to user interactions

- (void)endEditing {
    [self.tableView endEditing:YES];
}

- (void)tappedProgressPicker:(ProgressPickerButton *)button {
    self.selectedProgress = button.type;
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
    if (self.urlOfSelectedVideo) {
        self.currentSnapshot.notes = self.textView.text;
        [self.currentSnapshot setProgressTypeRaw:self.selectedProgress];
        [self addVideoToSnapshotAtUrl:self.urlOfSelectedVideo];
        
        [self.delegate addSnapshotTableViewControllerDidSave];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing video"
                                                        message:@"A snapshot cannot be saved without a video. Pick a video and try again."
                                                       delegate:nil
                                              cancelButtonTitle:@"Okay"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)pickPhoto:(id)sender {
    if (!self.sheet) {
        [self setupActionSheet];
    }
    
    [self.sheet showInView:self.view];
}

- (void)addVideoToSnapshotAtUrl:(NSURL *)mediaUrl {
    [self.currentSnapshot saveVideoAtFileUrl:mediaUrl completionBlock:^{} failureBlock:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Saving failed"
                                    message:@"Sorry but there was a problem saving the video"
                                   delegate:nil
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil] show];
    }];
}

#pragma mark - table view

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1 && [self.currentSnapshot isBaseline]) {
        return @"The first snapshot is considered the baseline, so you can't rate it. You will be able to when you add the next snapshot.";
    }
    
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.previousSnapshot == nil) {
        return [super numberOfSectionsInTableView:tableView] - 1;
    } else {
        return [super numberOfSectionsInTableView:tableView];
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

#pragma mark - picking video

- (void)videoPicker:(VideoPicker *)picker didPickVideoAtUrl:(NSURL *)url {
    self.urlOfSelectedVideo = url;
    [self showThumbnailOfVideoAnimated:YES];
}

- (void)showThumbnailOfVideoAnimated:(BOOL)animated {
    self.pickedVideoPreview.videoUrl = self.urlOfSelectedVideo;
    self.pickedVideoPreview.hidden = NO;

    VideoEditor *editor = [[VideoEditor alloc] init];
    self.pickedVideoPreview.image = [editor thumbnailForVideoAtUrl:self.urlOfSelectedVideo];

    self.pickedVideoPreview.delegate = self;

    [self.pickedVideoPreview awakeFromNib];
}

#pragma mark - ImageViewSnapshot delegate methods

- (void)imageViewWithSnapshot:(VideoPreview *)imageView presentMoviePlayerViewControllerAnimated:(AVPlayerViewController *)player {
    [self presentViewController:player animated:YES completion:^() {
        [player.player play];
    }];
}

#pragma mark - text view methods

- (void)setupNotesView {
    self.textView.textViewDelegate = self;
    self.textView.automaticallyAdjustsContentInsetForKeyboard = NO;
    self.initialTextViewHeight = self.textView.frame.size.height;
    self.textView.textContainerInset = UIEdgeInsetsMake(7, 7, 7, 7);
    
    if (self.currentSnapshot.notes) {
        self.textView.text = self.currentSnapshot.notes;
        [self textViewDidChange:self.textView];
    }
    
    UITapGestureRecognizer *tapper =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(endEditing)];
    [self.tableView addGestureRecognizer:tapper];
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
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:numberOfRows-1 inSection:2];
        [self.tableView scrollToRowAtIndexPath:indexPath
                              atScrollPosition:UITableViewScrollPositionBottom
                                      animated:animated];
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
