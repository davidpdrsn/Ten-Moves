//
//  LPBlockActionSheet.h
//  ActionSheetBlocks
//
//  Created by David Pedersen on 10/08/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPBlockActionSheet : NSObject

@property (nonatomic, copy) void (^willDismissCallBack)();
@property (nonatomic, copy) void (^willPresentCallBack)();

@property (nonatomic, copy) void (^didDismissCallBack)();
@property (nonatomic, copy) void (^didPresentCallBack)();

- (void)setTitle:(NSString *)title;
- (void)setDesctructiveButtonTitle:(NSString *)title block:(void (^)())block;
- (void)setCancelButtonTitle:(NSString *)title block:(void (^)())block;
- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block;
- (void)showInView:(UIView *)view;

@end
