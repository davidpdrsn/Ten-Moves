//
//  PopularMovesTableViewController.h
//  TenMoves
//
//  Created by David Pedersen on 16/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SuggestedMovesTableViewController;

@protocol PopularMovesTableViewControllerDelegate <NSObject>

- (void)popularMovesTableViewController:(SuggestedMovesTableViewController *)controller tappedMoveWithName:(NSString *)name;
- (void)popularMovesTableViewControllerDidLoadMoves:(SuggestedMovesTableViewController *)controller;

@end

@interface SuggestedMovesTableViewController : UITableViewController

@property (strong, nonatomic) id<PopularMovesTableViewControllerDelegate> delegate;

- (void)loadPopularMoves;
- (void)loadResultsFromSearch:(NSString *)query;

@end
