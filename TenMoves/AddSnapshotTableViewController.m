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
#import "VideoPreview.h"
#import "ALAssetsLibrary+HelperMethods.h"
#import "Move.h"
#import "VideoEditor.h"
#import "LPBlockActionSheet.h"
#import "SnapshotVideo.h"
#import "UIView+Autolayout.h"

@interface AddSnapshotTableViewController ()

@property (strong, nonatomic) VideoPreview *videoPreview;
@property (assign, nonatomic) BOOL resizedButton;

@property (strong, nonatomic) NSArray *progressButtons;

@property (weak, nonatomic) IBOutlet UITableViewCell *progressCell;
@property (weak, nonatomic) IBOutlet UIButton *pickVideoButton;
@property (weak, nonatomic) IBOutlet UIView *progressPickerContainer;

@property (assign, nonatomic) SnapshotProgress selectedProgress;
@property (strong, nonatomic) NSURL *urlOfSelectedVideo;

@property (weak, nonatomic) IBOutlet JTSTextView *textView;
@property (assign, nonatomic) CGFloat initialTextViewHeight;

@property (strong, nonatomic) LPBlockActionSheet *sheet;

@end

@implementation AddSnapshotTableViewController

#pragma mark - view life cycle

- (void)setupProgressPickers {
    ProgressPickerButton *improved = [ProgressPickerButton autolayoutView];
    [self.progressPickerContainer addSubview:improved];
    [improved constrainFlushTopBottom];
    [improved constrainWidthToRatio:.333333];
    [improved constrainFlushLeft];
    improved.type = SnapshotProgressImproved;
    improved.label.text = [Snapshot textForProgressType:SnapshotProgressImproved];
    [improved addTarget:self action:@selector(tappedProgressPicker:) forControlEvents:UIControlEventTouchUpInside];
    improved.hasBorder = YES;

    ProgressPickerButton *same = [ProgressPickerButton autolayoutView];
    [self.progressPickerContainer addSubview:same];
    [same constrainFlushTopBottom];
    [same constrainWidthToRatio:.333333];
    [same constrainCenterHorizontally];
    same.type = SnapshotProgressSame;
    same.label.text = [Snapshot textForProgressType:SnapshotProgressSame];
    [same addTarget:self action:@selector(tappedProgressPicker:) forControlEvents:UIControlEventTouchUpInside];
    same.hasBorder = YES;
    
    ProgressPickerButton *regressed = [ProgressPickerButton autolayoutView];
    [self.progressPickerContainer addSubview:regressed];
    [regressed constrainFlushTopBottom];
    [regressed constrainWidthToRatio:.333333];
    [regressed constrainFlushRight];
    regressed.type = SnapshotProgressRegressed;
    regressed.label.text = [Snapshot textForProgressType:SnapshotProgressRegressed];
    [regressed addTarget:self action:@selector(tappedProgressPicker:) forControlEvents:UIControlEventTouchUpInside];
    
    self.progressButtons = @[improved, same, regressed];
    
    [self updateActiveProgressPicker];
}

- (void)tappedProgressPicker:(ProgressPickerButton *)button {
    self.selectedProgress = button.type;
    [self updateActiveProgressPicker];
}

- (void)updateActiveProgressPicker {
    for (ProgressPickerButton *button in self.progressButtons) {
        [button setActive:(self.selectedProgress == button.type) animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedProgress = self.currentSnapshot.progressTypeRaw;
    
    [self setupProgressPickers];
    
    if ([self.currentSnapshot isBaseline]) {
        self.progressCell.userInteractionEnabled = NO;
        for (ProgressPickerButton *button in self.progressButtons) {
            button.enabled = NO;
        }
    }
    
    [self configureTextView];
    
    UITapGestureRecognizer *tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(endEditing)];
    [self.tableView addGestureRecognizer:tapper];
    
    if (self.currentSnapshot.video) {
        self.urlOfSelectedVideo = [self.currentSnapshot.video url];
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Snapshot must have video" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alert show];
    }
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
    
    self.sheet.willPresentCallBack = ^{
        _self.videoPreview.enabled = NO;
        
        for (ProgressPickerButton *button in _self.progressButtons) { button.enabled = NO; }
    };
    
    self.sheet.willDismissCallBack = ^{
        _self.videoPreview.enabled = YES;
        
        if (![_self.currentSnapshot isBaseline]) {
            for (ProgressPickerButton *button in _self.progressButtons) { button.enabled = YES; }
        }
    };
}

#pragma mark - table view

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1 && [self.currentSnapshot isBaseline]) {
        return @"The first snapshot is considered the baseline, so you can't rate it. You will be able to when you add the next snapshot.";
    }
    
    return nil;
}

#pragma mark - picking video

- (void)startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate, UINavigationControllerDelegate>) delegate
                                       type:(UIImagePickerControllerSourceType)type {
    if (([UIImagePickerController isSourceTypeAvailable: type] == NO) || (delegate == nil) || (controller == nil)) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video recording not supported" message:@"Your phone does not support video recording" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed importing video" message:nil delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    [alert show];
}

- (void)addVideoToSnapshotAtUrl:(NSURL *)mediaUrl {
    [self.currentSnapshot saveVideoAtFileUrl:mediaUrl completionBlock:^{} failureBlock:^(NSError *error) {}];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
    
    BOOL videoWasEdited = info[@"_UIImagePickerControllerVideoEditingStart"] && info[@"_UIImagePickerControllerVideoEditingEnd"];
    if (videoWasEdited) {
        NSNumber *start = [info objectForKey:@"_UIImagePickerControllerVideoEditingStart"];
        NSNumber *end = [info objectForKey:@"_UIImagePickerControllerVideoEditingEnd"];
        
        VideoEditor *editor = [[VideoEditor alloc] init];
        [editor trimVideoAtUrl:mediaUrl start:start end:end completionBlock:^(NSURL *urlOfTrimmedVideo) {
            self.urlOfSelectedVideo = urlOfTrimmedVideo;
            [self showThumbnailOfVideoAnimated:YES];
        } failureBlock:^(NSError *error) {
            [self showVideoCopyAlert];
        }];
    } else {
        self.urlOfSelectedVideo = mediaUrl;
        [self showThumbnailOfVideoAnimated:YES];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)showThumbnailOfVideoAnimated:(BOOL)animated {
    int offset = 5;
    CGFloat size = self.pickVideoButton.superview.frame.size.height-offset*2;
    
    CGRect frame = CGRectMake(offset, offset, size, size);
    
    if (self.videoPreview) {
        [self.videoPreview removeFromSuperview];
    }
    
    self.videoPreview = [[VideoPreview alloc] initWithFrame:frame];
    self.videoPreview.tintColor = self.view.tintColor;
    
    VideoEditor *editor = [[VideoEditor alloc] init];
    self.videoPreview.image = [editor thumbnailForVideoAtUrl:self.urlOfSelectedVideo];
    self.videoPreview.videoUrl = self.urlOfSelectedVideo;
    self.videoPreview.delegate = self;
    
    [self.pickVideoButton.superview addSubview:self.videoPreview];
    
    [self.videoPreview awakeFromNib];
    
    if (!self.resizedButton) {
        self.resizedButton = YES;
        
        CGPoint destination = self.videoPreview.center;
        self.videoPreview.center = CGPointMake(self.videoPreview.center.x-(self.videoPreview.frame.size.width+offset), self.videoPreview.center.y);
        
        void (^showThumbnail)() = ^void() {
            self.videoPreview.center = destination;
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

- (void)imageViewWithSnapshot:(VideoPreview *)imageView presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)player {
    [self presentMoviePlayerViewControllerAnimated:player];
}

- (void)imageViewWithSnapshotDismissMoviePlayerViewControllerAnimated:(VideoPreview *)imageView {
    [self dismissMoviePlayerViewControllerAnimated];
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
