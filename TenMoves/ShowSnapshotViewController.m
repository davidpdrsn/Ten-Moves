//
//  ShowSnapshotViewController.m
//  TenMoves
//
//  Created by David Pedersen on 30/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ShowSnapshotViewController.h"
@import MediaPlayer;
#import "Snapshot.h"
#import "VideoPreview.h"
#import "Repository.h"
#import "NSDate+Helpers.h"
#import "AddSnapshotTableViewController.h"
#import "SnapshotVideo.h"
#import "JTSTextView.h"
#import "Move.h"

@interface ShowSnapshotViewController ()

@property (weak, nonatomic) IBOutlet VideoPreview *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *progressCircle;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet JTSTextView *notesTextView;
@property (weak, nonatomic) IBOutlet UILabel *moveLabel;

@property (strong, nonatomic) Snapshot *nextSnapshot;
@property (strong, nonatomic) Snapshot *prevSnapshot;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *prevButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;

@end

@implementation ShowSnapshotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterLongStyle;
    
    self.dateLabel.text = [formatter stringFromDate:self.snapshot.createdAt];
    
    [self.thumbnail setVideoAndImageFromSnapshot:self.snapshot];
    self.thumbnail.tintColor = self.view.tintColor;
    [self.thumbnail awakeFromNib];
    self.thumbnail.delegate = self;
    
    self.progressCircle.layer.cornerRadius = self.progressCircle.frame.size.height/2;
    self.progressCircle.backgroundColor = [self.snapshot colorForProgressType];
    
    self.progressLabel.text = [self.snapshot textForProgressType];
    
    self.moveLabel.text = self.snapshot.move.name;
    
    [self configureNotesView];
    
    [self configureNextAndPrev];
    
    [self configureTitle];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureNotesView];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)configureTitle {
    NSDate *date = self.snapshot.createdAt;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM";
    
    NSString *month = [formatter stringFromDate:date];
    
    formatter.dateFormat = @"dd";
    NSString *day = [NSString stringWithFormat:@"%@%@", [formatter stringFromDate:date], [date daySuffix]];
    
    self.title = [NSString stringWithFormat:@"%@ %@", month, day];
}

- (void)configureNextAndPrev {
    if (!self.nextSnapshot)
        self.nextButton.enabled = NO;
    else
        self.nextButton.enabled = YES;
    
    if (!self.prevSnapshot)
        self.prevButton.enabled = NO;
    else
        self.prevButton.enabled = YES;
}

- (void)configureNotesView {
    self.notesTextView.editable = NO;
    self.notesTextView.delegate = self;
    self.notesTextView.scrollEnabled = NO;
    self.notesTextView.textViewDelegate = self;
    self.notesTextView.textContainerInset = UIEdgeInsetsMake(0,0,0,0);
    
    if ([self.snapshot hasNotes]) {
        self.notesTextView.text = self.snapshot.notes;
        self.notesTextView.textColor = [UIColor blackColor];
    } else {
        self.notesTextView.text = @"No notes";
        self.notesTextView.textColor = [UIColor lightGrayColor];
    }
    
    [self.notesTextView sizeToFit];
    [self textViewDidChange:self.notesTextView];
}

- (void)textViewDidChange:(JTSTextView *)textView {
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 2 && indexPath.row == 0) {
        CGFloat contentSize = self.notesTextView.contentSize.height + 8;
        return (contentSize < 44) ? 44 : contentSize;
    } else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

- (void)showSnapshot:(Snapshot *)snapshot {
    self.snapshot = snapshot;
    [self viewDidLoad];
    [self configureNextAndPrev];
}

- (IBAction)next:(UIBarButtonItem *)sender {
    if (self.nextSnapshot) {
        [self showSnapshot:self.nextSnapshot];
    }
}

- (IBAction)prev:(UIBarButtonItem *)sender {
    if (self.prevSnapshot) {
        [self showSnapshot:self.prevSnapshot];
    }
}

- (void)setSnapshot:(Snapshot *)snapshot {
    _snapshot = snapshot;

    NSFetchRequest *fetchRequest = [Snapshot fetchRequestForSnapshotsBelongingToMove:self.snapshot.move];
    [Repository executeFetch:fetchRequest completionBlock:^(NSArray *results) {
        NSUInteger index = [results indexOfObject:self.snapshot];
        NSInteger nextIndex = index+1;
        NSInteger prevIndex = index-1;
        
        if (results.count-1 >= nextIndex) {
            self.nextSnapshot = results[index+1];
        } else {
            self.nextSnapshot = nil;
        }
        
        if (0 <= prevIndex) {
            self.prevSnapshot = results[index-1];
        } else {
            self.prevSnapshot = nil;
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error.userInfo);
    }];
}

- (void)imageViewWithSnapshot:(VideoPreview *)imageView presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)player {
    [self presentMoviePlayerViewControllerAnimated:player];
}

- (void)imageViewWithSnapshotDismissMoviePlayerViewControllerAnimated:(VideoPreview *)imageView {
    [self dismissMoviePlayerViewControllerAnimated];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"editSnapshot"]) {
        UINavigationController *nav = (UINavigationController *)segue.destinationViewController;
        AddSnapshotTableViewController *add = (AddSnapshotTableViewController *)nav.topViewController;
        add.currentSnapshot = self.snapshot;
        add.delegate = self;
        add.editingSnapshot = YES;
    }
}

- (void)addSnapshotTableViewControllerDidSave {
    [Repository saveWithCompletionHandler:nil];
    [self dismissAddSnapshotTableViewController];
}

- (void)addSnapshotTableViewControllerDidCancel:(Snapshot *)snapshotToDelete {
    [self dismissAddSnapshotTableViewController];
}

- (void)dismissAddSnapshotTableViewController {
    [self viewDidLoad];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
