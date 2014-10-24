//
//  PopularMovesTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 16/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "PopularMovesTableViewController.h"
#import "API.h"

@interface PopularMovesTableViewController ()

@property (strong, nonatomic) NSArray *popularMoves;

@end

@implementation PopularMovesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self fetchPopularMoves];
}

- (void)fetchPopularMoves {
    [[API sharedInstance] getMoves:^(id moves, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"error getting moves"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            self.popularMoves = moves;
            [self.tableView reloadData];
            [self.delegate popularMovesTableViewControllerDidLoadMoves:self];
        }
    }];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.popularMoves.count > 0) ? self.popularMoves.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.popularMoves == nil) {
        return [tableView dequeueReusableCellWithIdentifier:@"spinnerCell"];
    } else if (self.popularMoves.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"popularMoveCell"];
        cell.textLabel.text = @"No popular moves found...";
        cell.textLabel.textColor = [UIColor lightGrayColor];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"popularMoveCell"];
        cell.textLabel.text = self.popularMoves[indexPath.row];
        return cell;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Popular moves";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"Popular moves that other users are practicing";
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.popularMoves.count > 0) {
        NSString *name = self.popularMoves[indexPath.row];
        [self.delegate popularMovesTableViewController:self tappedMoveWithName:name];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

@end
