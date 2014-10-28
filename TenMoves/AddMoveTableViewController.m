//
//  AddMoveViewController.m
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "AddMoveTableViewController.h"
#import "Move.h"
#import "SuggestedMovesTableViewController.h"
#import "DGPThrottledBlock.h"

@interface AddMoveTableViewController () <PopularMovesTableViewControllerDelegate> {
    UIBarButtonItem *addButton;
}

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (strong, nonatomic) SuggestedMovesTableViewController *popularMovesViewController;
@property (strong, nonatomic) DGPThrottledBlock *reloadBlock;

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
    
    [self.nameField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
    
    self.reloadBlock = [[DGPThrottledBlock alloc] initWithBlock:^{
        [self reloadSuggestions];
    } throttleDay:0.3];
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
        SuggestedMovesTableViewController *destination = (SuggestedMovesTableViewController *)segue.destinationViewController;
        destination.delegate = self;
        [destination loadPopularMoves];
        
        self.popularMovesViewController = destination;
    }
}

- (void)popularMovesTableViewController:(SuggestedMovesTableViewController *)controller tappedMoveWithName:(NSString *)name {
    self.nameField.text = name;
    [self textFieldDidChange:self.nameField];
}

- (void)popularMovesTableViewControllerDidLoadMoves:(SuggestedMovesTableViewController *)controller {
    UITableView *view = (UITableView *)controller.view;
    CGSize newSize = view.contentSize;
    CGRect newFrame = self.containerView.frame;
    newFrame.size = newSize;
    self.containerView.frame = newFrame;
}

- (void)textFieldDidChange:(UITextField *)field {
    [self.reloadBlock start];
}

- (void)reloadSuggestions {
    if ([self.nameField.text isEqualToString:@""]) {
        [self.popularMovesViewController loadPopularMoves];
    } else {
        NSString *query = self.nameField.text;
        [self.popularMovesViewController loadResultsFromSearch:query];
    }
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

#pragma mark - table view methods

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section != 0 && indexPath.row != 0;
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
