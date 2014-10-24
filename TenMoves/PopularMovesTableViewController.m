//
//  PopularMovesTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 16/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "PopularMovesTableViewController.h"
#import "AFNetworking/AFNetworking.h"

@interface PopularMovesTableViewController ()

@property (strong, nonatomic) NSArray *popularMoves;

@end

@implementation PopularMovesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#ifdef DEBUG
    NSLog(@"Only log when in debug");
#endif

    [self fetchPopularMoves];
}

- (void)fetchPopularMoves {
    NSDictionary *params = @{ @"api_key": @"027b311dc95c1613a2d05e99b7d6bd4079b7414c" };
    
    NSString *url;
#ifdef DEBUG
    url = @"http://tenmoves-api.dev";
#else
    url = @"http://tenmovesapi.herokuapp.com";
#endif

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[url stringByAppendingPathComponent:@"moves"] parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        self.popularMoves = responseObject;

        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
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
    return @"These are some popular moves that other users are practicing";
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.popularMoves.count == 0) {
        NSString *name = self.popularMoves[indexPath.row];
        [self.delegate popularMovesTableViewController:self tappedMoveWithName:name];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    });
}

@end
