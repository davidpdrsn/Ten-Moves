//
//  ImageViewWithSnapshot.h
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snapshot.h"

@interface ImageViewWithSnapshot : UIImageView

@property (strong, nonatomic) Snapshot *snapshot;

- (void)setBackground;

@end
