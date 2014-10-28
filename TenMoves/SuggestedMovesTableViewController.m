//
//  PopularMovesTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 16/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "SuggestedMovesTableViewController.h"
#import "API.h"

@interface SuggestedMovesTableViewController ()

@property (strong, nonatomic) NSArray *popularMoves;
@property (strong, nonatomic) NSError *fetchError;

@end

@implementation SuggestedMovesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)loadPopularMoves {
    [[API sharedInstance] getPopularMoves:^(id moves, NSError *error) {
        if (error) {
            self.fetchError = error;
        } else {
            self.popularMoves = moves;
        }
        
        [self doneLoading];
    }];
}

- (void)loadResultsFromSearch:(NSString *)query {
    
    [[API sharedInstance] getMovesMatchingQuery:query completionBlock:^(id moves, NSError *error) {
        if (error) {
            self.fetchError = error;
        } else {
            self.popularMoves = moves;
        }
        
        [self doneLoading];
    }];
}

- (void)doneLoading {
    [self.tableView reloadData];
    [self.delegate popularMovesTableViewControllerDidLoadMoves:self];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (self.popularMoves.count > 0) ? self.popularMoves.count : 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.fetchError) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"errorCell"];
        cell.textLabel.text = @"Error getting moves, try again later";
        cell.textLabel.textColor = [UIColor lightGrayColor];
        return cell;
    }
    
    if (self.popularMoves == nil) {
        return [tableView dequeueReusableCellWithIdentifier:@"spinnerCell"];
    }
    
    if (self.popularMoves.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"popularMoveCell"];
        cell.textLabel.text = @"No popular moves found...";
        cell.textLabel.textColor = [UIColor lightGrayColor];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"popularMoveCell"];
    cell.textLabel.text = self.popularMoves[indexPath.row];
    cell.textLabel.textColor = [UIColor blackColor];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Suggested moves";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return @"These are moves that users are practicing";
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
