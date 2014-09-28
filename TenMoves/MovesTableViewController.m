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
#import "Constants.h"
#import "AddMoveTableViewController.h"
#import "ArrayDataSource.h"
#import "GraphAndSnapshotsViewController.h"

@interface MovesTableViewController ()

@property (strong, nonatomic) ArrayDataSource *dataSource;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addButton;

@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *websiteButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;

@end

@implementation MovesTableViewController

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.dataSource = [self createDataSource];
    self.dataSource.delegate = self;
    self.dataSource.emptyTableViewHeaderText = @"Zero Moves";
    self.dataSource.emptyTableViewText = @"It seems you haven't added any moves yet. Tap the plus button to get started.";
    
    [self hideOrShowAdditionalControls];
    
    self.tableView.delegate = self.dataSource;
    self.tableView.dataSource = self.dataSource;
    self.tableView.emptyDataSetDelegate = self.dataSource;
    self.tableView.emptyDataSetSource = self.dataSource;
    
    self.editButtonItem.accessibilityLabel = @"Edit";
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.tableView.allowsSelectionDuringEditing = YES;
    
    self.tableView.delegate = self;
    
    self.bottomView.backgroundColor = [UIColor clearColor];
}

- (IBAction)websiteButtonTapped:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://tenmoves.net"];
    [[UIApplication sharedApplication] openURL:url];
}

- (IBAction)twitterButtonTapped:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/tenmovesapp"];
    [[UIApplication sharedApplication] openURL:url];
}

-  (void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.dataSource reload];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

#pragma mark - segue

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.tableView.isEditing) {
        [self performSegueWithIdentifier:@"editMove" sender:self];
    } else {
        [self performSegueWithIdentifier:@"showSnapshots" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    BOOL isEditingSegue = [segue.identifier isEqualToString:@"editMove"];

    if ([segue.identifier isEqualToString:@"showSnapshots"]) {
        GraphAndSnapshotsViewController *destination = (GraphAndSnapshotsViewController *) segue.destinationViewController;
        Move *move = [self.dataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
        destination.move = move;
    } else if ([segue.identifier isEqualToString:@"AddMove"] || isEditingSegue) {
        UINavigationController *nav = (UINavigationController *)segue.destinationViewController;
        AddMoveTableViewController *add = (AddMoveTableViewController *)nav.topViewController;
        add.delegate = self;
        
        if (isEditingSegue) {
            add.editingMove = YES;
            add.currentMove = (Move *)[self.dataSource itemAtIndexPath:[self.tableView indexPathForSelectedRow]];
        } else {
            add.currentMove = [Move newManagedObject];
        }
    }
}

#pragma mark - add move view controller delegate

- (void)addMoveViewControllerDidSave {
    [Repository saveWithCompletionHandler:^(NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Missing name"
                                                            message:@"Are you sure the move has a name?"
                                                           delegate:nil
                                                  cancelButtonTitle:@"I'll look into it"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            [self dismissAddMoveViewController];
        }
    }];
    
    [self hideOrShowAdditionalControls];
}

- (void)addMoveViewControllerDidCancel:(Move *)moveToDelete {
    [Repository deleteObject:moveToDelete];
    [self dismissAddMoveViewController];
}

- (void)dismissAddMoveViewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - array data source delegate

- (ArrayDataSource *)createDataSource {
    ConfigureCellBlock configureCell = ^UITableViewCell *(UITableViewCell *cell, Move *move) {
        MoveTableViewCell *moveCell = (MoveTableViewCell *)cell;
        moveCell.nameLabel.text = move.name;
        moveCell.countLabel.text = [NSString stringWithFormat:@"%i", (int)move.snapshots.count];
        moveCell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
        moveCell.accessibilityLabel = move.name;

        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        moveCell.detailTextLabel.text = [formatter stringFromDate:move.createdAt];
        
        return moveCell;
    };
    
    return [[ArrayDataSource alloc] initWithItems:[Move fetchRequest]
                                   cellIdentifier:@"Move"
                               configureCellBlock:configureCell];
}

- (NSString *)arrayDataSource:(ArrayDataSource *)arrayDataSource textForFooterView:(NSArray *)objects {
    if (objects.count == 0) {
        return nil;
    } else {
        NSInteger remaining = MAX_NUMBER_OF_MOVES - objects.count;
        if (remaining == 0) {
            return @"You have no slots remaining";
        } else {
            NSString *quantifier = (remaining == 1) ? @"slot" : @"slots";
            return [NSString stringWithFormat:@"You have %i %@ remaining", (int)remaining, quantifier];
        }
    }
}

- (void)arrayDataSourceDidChangeData:(ArrayDataSource *)arrayDataSource {
    [self hideOrShowAdditionalControls];
}

#pragma mark - misc helper methods

- (void)hideOrShowAdditionalControls {
    [self enableOrDisableAddButton];
    [self hideOrShowBottomView];
    [self enableOrDisableEditButton];
}

- (void)enableOrDisableAddButton {
    self.addButton.enabled = [self.dataSource totalNumberOfObjects] < MAX_NUMBER_OF_MOVES;
}

- (void)hideOrShowBottomView {
    self.bottomView.hidden = [self.dataSource totalNumberOfObjects] == 0;
}

- (void)enableOrDisableEditButton {
    if ([self.dataSource totalNumberOfObjects] == 0) {
        [self setEditing:NO animated:YES];
        self.editButtonItem.enabled = NO;
    } else {
        self.editButtonItem.enabled = YES;
    }
}

@end

