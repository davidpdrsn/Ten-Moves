//
//  LPBlockActionSheet.m
//  ActionSheetBlocks
//
//  Created by David Pedersen on 10/08/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "LPBlockActionSheet.h"

@interface LPBlockActionSheet () <UIActionSheetDelegate>

@property (strong, nonatomic) UIActionSheet *actionSheet;

@property (strong, nonatomic) NSString *cancelButtonTitle;
@property (strong, nonatomic) NSString *destructiveButtonTitle;
@property (strong, nonatomic) NSMutableArray *buttonTitles;

@property (nonatomic, copy) void (^cancelBlock)();
@property (nonatomic, copy) void (^destructiveBlock)();
@property (strong, nonatomic) NSMutableArray *buttonBlocks;

@property (assign, nonatomic) NSInteger cancelButtonIndex;
@property (assign, nonatomic) NSInteger destructiveButtonIndex;

@end

@implementation LPBlockActionSheet

- (instancetype)init {
    self = [super init];
    if (self) {
        self.buttonTitles = [NSMutableArray array];
        self.buttonBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    self.actionSheet.title = title;
}

- (void)setDesctructiveButtonTitle:(NSString *)title block:(void (^)())block {
    self.destructiveButtonTitle = title;
    self.destructiveBlock = block;
}

- (void)setCancelButtonTitle:(NSString *)title block:(void (^)())block {
    self.cancelButtonTitle = title;
    self.cancelBlock = block;
}

- (void)addButtonWithTitle:(NSString *)title block:(void (^)())block {
    [self.buttonTitles addObject:title];
    [self.buttonBlocks addObject:block];
}

- (void)showInView:(UIView *)view {
    if (!self.actionSheet) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:nil
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:nil];
        
        NSMutableArray *titles = [NSMutableArray arrayWithArray:self.buttonTitles];
        
        if (self.destructiveButtonTitle) {
            [titles addObject:self.destructiveButtonTitle];
            self.actionSheet.destructiveButtonIndex = titles.count - 1;
        }
        
        if (self.cancelButtonTitle) {
            [titles addObject:self.cancelButtonTitle];
            self.actionSheet.cancelButtonIndex = titles.count - 1;
        }
        
        for (NSString *title in titles) {
            [self.actionSheet addButtonWithTitle:title];
        }
    }
    
    [self.actionSheet showInView:view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSMutableArray *blocks = [NSMutableArray arrayWithArray:self.buttonBlocks];
    
    if (self.destructiveBlock) {
        [blocks addObject:self.destructiveBlock];
    }
    
    if (self.cancelBlock) {
        [blocks addObject:self.cancelBlock];
    }
    
    void (^block)() = blocks[buttonIndex];
    block();
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet {
    if (self.willPresentCallBack) {
        self.willPresentCallBack();
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (self.willDismissCallBack) {
        self.willDismissCallBack();
    }
}

@end
