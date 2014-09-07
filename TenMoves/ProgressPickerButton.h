//
//  ProgressBaseView.h
//  TenMoves
//
//  Created by David Pedersen on 23/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
// TODO: maybe I shouldn't have to import this header here...
#import "Snapshot.h"

@interface ProgressPickerButton : UIButton

@property (assign, nonatomic) SnapshotProgress type;
@property (strong, nonatomic) UILabel *label;
@property (assign, nonatomic) BOOL hasBorder;

- (void)setActive:(BOOL)active animated:(BOOL)animated;

@end
