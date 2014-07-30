//
//  AddMoveViewController.h
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddMoveTableViewControllerDelegate.h"

@class Move;

@interface AddMoveTableViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, strong) Move *currentMove;
@property (nonatomic, strong) id<AddMoveTableViewControllerDelegate> delegate;

@end
