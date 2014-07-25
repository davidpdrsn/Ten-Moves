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

- (void)resizeToFit:(CGRect)parentFrame;
- (void)setProgressType:(SnapshotProgress)type;
- (void)setLabelText:(NSString *)text;
- (void)setShowBorder:(BOOL)shouldShowBorder;

@end
