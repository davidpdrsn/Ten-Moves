//
//  MoveTableViewCell.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "MoveTableViewCell.h"

@implementation MoveTableViewCell

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    
    [UIView animateWithDuration:.25 animations:^{
        if (editing) {
            self.countLabel.layer.opacity = 0;
        } else {
            self.countLabel.layer.opacity = 1;
        }
    }];
}

@end
