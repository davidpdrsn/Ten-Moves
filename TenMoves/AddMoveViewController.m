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

    self.nameField.text = [self.currentMove name];
    self.nameField.delegate = self;
    
    self.title = @"Add new move";
    
    addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(add)];
    addButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = addButton;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancel)];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.nameField becomeFirstResponder];
}

- (void)add {
    self.currentMove.name = self.nameField.text;
    
    [self.delegate addCourseViewControllerDidSave];
}

- (void)cancel {
    [self.delegate addCourseViewControllerDidCancel:self.currentMove];
}

#pragma mark - text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self add];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSRange textFieldRange = NSMakeRange(0, [textField.text length]);
    if (NSEqualRanges(range, textFieldRange) && [string length] == 0) {
        addButton.enabled = NO;
    } else {
        addButton.enabled = YES;
    }
    
    return YES;
}

@end
