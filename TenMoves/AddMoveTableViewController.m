//
//  AddMoveViewController.m
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "AddMoveTableViewController.h"
#import "Move.h"
#import "PopularMovesTableViewController.h"

@interface AddMoveTableViewController () <PopularMovesTableViewControllerDelegate> {
    UIBarButtonItem *addButton;
}

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation AddMoveTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNameField];
    
    if (self.editingMove) {
        self.title = @"Edit move";
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(endEditing)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
}

- (void)endEditing {
    [self.nameField resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditing];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.nameField becomeFirstResponder];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"embedPopularMoves"]) {
        PopularMovesTableViewController *destination = (PopularMovesTableViewController *)segue.destinationViewController;
        destination.delegate = self;
    }
}

- (void)popularMovesTableViewController:(PopularMovesTableViewController *)controller tappedMoveWithName:(NSString *)name {
    self.nameField.text = name;
}

- (void)popularMovesTableViewControllerDidLoadMoves:(PopularMovesTableViewController *)controller {
    UITableView *view = (UITableView *)controller.view;
    CGSize newSize = view.contentSize;
    CGRect newFrame = self.containerView.frame;
    newFrame.size = newSize;
    self.containerView.frame = newFrame;
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
    [self.currentMove save];
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
