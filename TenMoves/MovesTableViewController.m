//
//  MovesTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "MovesTableViewController.h"
#import "Move.h"
#import "MoveTableViewCell.h"
#import "SnapshotsTableViewController.h"
#import "Repository.h"

@interface MovesTableViewController ()

@property (strong, nonatomic) ArrayDataSource *dataSource;
@property (strong, nonatomic) UIBarButtonItem *addButton;

@end

@implementation MovesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [self createDataSource];
    self.dataSource.delegate = self;
    self.dataSource.emptyTableViewHeaderText = @"Zero Moves";
    self.dataSource.emptyTableViewText = @"It seems you haven't added any moves yet. Tap the plus button to get started.";
    
    self.addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addNewMove)];
    self.addButton.tintColor = self.view.tintColor;
    self.navigationItem.rightBarButtonItem = self.addButton;
    [self enableOrDisableAddButton];
    
    self.tableView.delegate = self.dataSource;
    self.tableView.dataSource = self.dataSource;
    self.tableView.emptyDataSetDelegate = self.dataSource;
    self.tableView.emptyDataSetSource = self.dataSource;
}

- (void)addNewMove {
    UIStoryboard *storyBoard = [self storyboard];
    AddMoveViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"AddMoveViewController"];
    Move *move = [Move newManagedObject];
    vc.currentMove = move;
    vc.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)enableOrDisableAddButton {
    if ([self.dataSource totalNumberOfObjects] >= 10) {
        self.addButton.enabled = NO;
    } else {
        self.addButton.enabled = YES;
    }
}

#pragma mark - segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showSnapshots"]) {
        SnapshotsTableViewController *destination = (SnapshotsTableViewController *) segue.destinationViewController;
        destination.move = [self.dataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
    }
}

#pragma mark - add move view controller delegate

// TODO: this method does not belong here
- (void)addMoveViewControllerDidSave {
    [Repository saveWithCompletionHandler:^(NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing name" message:@"Are you sure the move has a name?" delegate:nil cancelButtonTitle:@"I'll look into it" otherButtonTitles:nil];
            [alert show];
        } else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    
    [self enableOrDisableAddButton];
}

// TODO: this method does not belong here
- (void)addMoveViewControllerDidCancel:(Move *)moveToDelete {
    [Repository deleteObject:moveToDelete];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (ArrayDataSource *)createDataSource {
    ConfigureCellBlock configureCell = ^UITableViewCell *(UITableViewCell *cell, Move *move) {
        MoveTableViewCell *moveCell = (MoveTableViewCell *)cell;
        moveCell.nameLabel.text = move.name;
        moveCell.countLabel.text = [NSString stringWithFormat:@"%i", (int)move.snapshots.count];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        moveCell.detailTextLabel.text = [formatter stringFromDate:move.createdAt];
        
        return moveCell;
    };
    
    return [[ArrayDataSource alloc] initWithItems:[Move fetchRequest]
                                   cellIdentifier:@"Move"
                               configureCellBlock:configureCell];
}

#pragma mark - array data source delegate

- (NSString *)arrayDataSource:(ArrayDataSource *)arrayDataSource textForFooterView:(NSArray *)objects {
    if (objects.count == 0) {
        return nil;
    } else {
        NSInteger remaining = 10 - objects.count;
        return [NSString stringWithFormat:@"You have %i slot(s) remaining", (int)remaining];
    }
}

- (void)arrayDataSourceDidChangeData:(ArrayDataSource *)arrayDataSource {
    [self enableOrDisableAddButton];
}

@end

