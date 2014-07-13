//
//  AddMoveViewController.h
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Move.h"

@protocol AddMoveViewControllerDelegate

- (void)addMoveViewControllerDidSave;
- (void)addMoveViewControllerDidCancel:(Move *)moveToDelete;

@end

@interface AddMoveViewController : UIViewController <UITextFieldDelegate>

@property (nonatomic, strong) Move *currentMove;
@property (nonatomic, strong) id<AddMoveViewControllerDelegate> delegate;

@end
