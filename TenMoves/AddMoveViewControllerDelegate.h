//
//  AddMoveViewControllerDelegate.h
//  TenMoves
//
//  Created by David Pedersen on 23/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Move;

@protocol AddMoveViewControllerDelegate

- (void)addMoveViewControllerDidSave;
- (void)addMoveViewControllerDidCancel:(Move *)moveToDelete;

@end
