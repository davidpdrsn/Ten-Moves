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
#import "NSString+RegExpHelpers.h"
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

    [self configureTitle];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.thumbnail awakeFromNib];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self configureNotesView];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (void)configureTitle {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    NSString *formattedDateString = [dateFormatter stringFromDate:self.snapshot.createdAt];
    self.title = formattedDateString;
}

- (void)configureNotesView {
    self.notesTextView.editable = NO;
    self.notesTextView.delegate = self;
    self.notesTextView.scrollEnabled = NO;
    self.notesTextView.textViewDelegate = self;
    self.notesTextView.textContainerInset = UIEdgeInsetsMake(0,0,0,0);
    
    if ([self.snapshot hasNotes]) {
        self.notesTextView.text = self.snapshot.notes;
        self.notesTextView.accessibilityLabel = self.snapshot.notes;
        self.notesTextView.textColor = [UIColor blackColor];
    } else {
        NSString *text = @"No notes";
        self.notesTextView.text = text;
        self.notesTextView.accessibilityLabel = text;
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
