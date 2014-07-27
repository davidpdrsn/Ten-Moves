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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1 && [self snapshotIsBaseline]) {
        return @"The first snapshot is considered the baseline, so you can't rate it. You will be able to when you add the next snapshot.";
    }
    
    return nil;
}

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

- (void)add {
    [self.delegate addSnapshotTableViewControllerDidSave];
}

- (IBAction)cancel:(id)sender {
    [self.delegate addSnapshotTableViewControllerDidCancel:self.currentSnapshot];
}

- (IBAction)done:(id)sender {
    [self add];
}

- (IBAction)pickPhoto:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths[0];
    
    NSString *videosPath = [documentsDirectory stringByAppendingPathComponent:@"/snapshot-videos"];
    NSString *imagesPath = [documentsDirectory stringByAppendingPathComponent:@"/snapshot-images"];
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    
    if (![manager fileExistsAtPath:videosPath]) {
        [manager createDirectoryAtPath:videosPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    if (![manager fileExistsAtPath:imagesPath]) {
        [manager createDirectoryAtPath:imagesPath withIntermediateDirectories:NO attributes:nil error:nil];
    }
    
    NSString *uuid = [self uuidString];
    NSString *filename = [NSString stringWithFormat:@"/%@.%@", uuid, mediaUrl.pathExtension];
    NSURL *videoDestinationUrl = [NSURL fileURLWithPath:[videosPath stringByAppendingString:filename]];
    
    [manager copyItemAtURL:mediaUrl toURL:videoDestinationUrl error:nil];
    
    self.currentSnapshot.videoPath = videoDestinationUrl.absoluteString;
    
    [self.pickVideoButton setTitle:@"Pick different video" forState:UIControlStateNormal];
    
    int offset = 5;
    CGFloat size = self.pickVideoButton.superview.frame.size.height-offset*2;
    ImageViewWithSnapshot *thumbnail = [[ImageViewWithSnapshot alloc] initWithFrame:CGRectMake(offset, offset, size, size)];
    
    [ALAssetsLibrary assetForURL:info[UIImagePickerControllerReferenceURL] resultBlock:^(ALAsset *asset) {
        UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
        NSData *imageData = UIImagePNGRepresentation(image);
        
        NSString *filename = [NSString stringWithFormat:@"/%@.png", uuid];
        NSURL *imageDestinationUrl = [NSURL fileURLWithPath:[imagesPath stringByAppendingString:filename]];
        
        self.currentSnapshot.imagePath = imageDestinationUrl.absoluteString;
        
        [imageData writeToURL:imageDestinationUrl atomically:YES];
        
        thumbnail.snapshot = self.currentSnapshot;
        thumbnail.delegate = self;
        [thumbnail awakeFromNib];
    } failureBlock:nil];
    
    [self.pickVideoButton.superview addSubview:thumbnail];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imageViewWithSnapshot:(ImageViewWithSnapshot *)imageView presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)player {
    [self presentMoviePlayerViewControllerAnimated:player];
}

- (void)imageViewWithSnapshotDismissMoviePlayerViewControllerAnimated:(ImageViewWithSnapshot *)imageView {
    [self dismissMoviePlayerViewControllerAnimated];
}


- (void)startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (([UIImagePickerController isSourceTypeAvailable: type] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = type;
    mediaUI.view.tintColor = self.view.tintColor;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    // TODO: set this to YES and figure out how to save the trimmed videos
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    [controller presentViewController:mediaUI animated:YES completion:nil];
}

- (NSString *)uuidString {
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid);
    CFRelease(uuid);
    
    return uuidString;
}

@end
