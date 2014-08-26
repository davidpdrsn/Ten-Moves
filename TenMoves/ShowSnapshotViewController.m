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
#import "ImageViewWithSnapshot.h"
#import "Repository.h"
#import "NSDate+Helpers.h"

@interface ShowSnapshotViewController ()

@property (weak, nonatomic) IBOutlet ImageViewWithSnapshot *thumbnail;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *progressCircle;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;

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
    
    self.thumbnail.snapshot = self.snapshot;
    self.thumbnail.tintColor = self.view.tintColor;
    [self.thumbnail awakeFromNib];
    self.thumbnail.delegate = self;
    
    self.progressCircle.layer.cornerRadius = self.progressCircle.frame.size.height/2;
    self.progressCircle.backgroundColor = [self.snapshot colorForProgressType];
    
    self.progressLabel.text = [self.snapshot textForProgressType];
    
    [self showNotesIfThereAreAny];
    
    [self configureNextAndPrev];
    
    [self configureTitle];
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

- (void)showNotesIfThereAreAny {
    if ([self.snapshot hasNotes]) {
        self.notesTextView.text = self.snapshot.notes;
        self.notesTextView.textColor = [UIColor blackColor];
    } else {
        self.notesTextView.text = @"This snapshot has no notes...";
        self.notesTextView.textColor = [UIColor lightGrayColor];
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

- (void)imageViewWithSnapshot:(ImageViewWithSnapshot *)imageView presentMoviePlayerViewControllerAnimated:(MPMoviePlayerViewController *)player {
    [self presentMoviePlayerViewControllerAnimated:player];
}

- (void)imageViewWithSnapshotDismissMoviePlayerViewControllerAnimated:(ImageViewWithSnapshot *)imageView {
    [self dismissMoviePlayerViewControllerAnimated];
}

@end
