//
//  AddMoveViewController.m
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "AddMoveViewController.h"

@interface AddMoveViewController () {
    UIBarButtonItem *addButton;
}

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation AddMoveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Add new move";
    [self setupNameField];
    [self setupNavigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.nameField becomeFirstResponder];
}

#pragma mark - setup view elements

- (void)setupNameField {
    self.nameField.text = [self.currentMove name];
    self.nameField.delegate = self;
}

- (void)setupNavigationBar {
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(add)];
    addButton.tintColor = self.view.tintColor;
    addButton.enabled = NO;
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    cancelButton.tintColor = self.view.tintColor;
    self.navigationItem.leftBarButtonItem = cancelButton;
}

#pragma mark - button actions

- (void)add {
    self.currentMove.name = self.nameField.text;
    
    [self.delegate addMoveViewControllerDidSave];
}

- (void)cancel {
    [self.delegate addMoveViewControllerDidCancel:self.currentMove];
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self add];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    [self enableOrDisableAddButtonWithTextField:textField string:string range:range];
    
    return YES;
}

- (void)enableOrDisableAddButtonWithTextField:(UITextField *)textField string:(NSString *)string range:(NSRange)range {
    NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
    if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
        addButton.enabled = NO;
    } else {
        addButton.enabled = YES;
    }
}

@end
