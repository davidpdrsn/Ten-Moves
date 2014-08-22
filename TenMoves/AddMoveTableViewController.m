//
//  AddMoveViewController.m
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "AddMoveTableViewController.h"
#import "Move.h"

@interface AddMoveTableViewController () {
    UIBarButtonItem *addButton;
}

@property (weak, nonatomic) IBOutlet UITextField *nameField;

@end

@implementation AddMoveTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNameField];
    
    if (self.editingMove) {
        self.title = @"Edit move";
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self.nameField becomeFirstResponder];
}

#pragma mark - setup view elements

- (void)setupNameField {
    self.nameField.text = self.currentMove.name;
    self.nameField.delegate = self;
}

#pragma mark - button actions
- (IBAction)done:(id)sender {
    [self add];
}

- (void)add {
    self.currentMove.name = self.nameField.text;
    [self.delegate addMoveViewControllerDidSave];
}

- (IBAction)cancel:(id)sender {
    if (self.editingMove) {
        [self.delegate dismissAddMoveViewController];
    } else {
        [self.delegate addMoveViewControllerDidCancel:self.currentMove];
    }
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
