//
//  PopularMovesTableViewController.h
//  TenMoves
//
//  Created by David Pedersen on 16/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PopularMovesTableViewController;

@protocol PopularMovesTableViewControllerDelegate <NSObject>

- (void)popularMovesTableViewController:(PopularMovesTableViewController *)controller tappedMoveWithName:(NSString *)name;

@end

@interface PopularMovesTableViewController : UITableViewController

@property (strong, nonatomic) id<PopularMovesTableViewControllerDelegate> delegate;

@end
