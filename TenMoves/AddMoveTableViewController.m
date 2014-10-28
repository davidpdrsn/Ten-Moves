//
//  AddMoveViewController.m
//  TenMoves
//
//  Created by David Pedersen on 10/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "AddMoveTableViewController.h"
#import "Move.h"
#import "DGPThrottledBlock.h"
#import "UIView+Autolayout.h"
#import "API.h"

@interface AddMoveTableViewController () {
    UIBarButtonItem *addButton;
}

@property (weak, nonatomic) UITextField *nameField;
@property (strong, nonatomic) NSArray *suggestedMoves;
@property (strong, nonatomic) NSError *fetchError;
@property (strong, nonatomic) DGPThrottledBlock *fetchBlock;

@end

@implementation AddMoveTableViewController

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.editingMove) {
        self.title = @"Edit move";
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(endEditing)];
    tap.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tap];
    
    self.fetchBlock = [[DGPThrottledBlock alloc] initWithBlock:^{
        [self loadSuggestedMoves];
    } throttleDay:0.3];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadSuggestedMoves];
}

- (void)endEditing {
    [self.nameField resignFirstResponder];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditing];
}

- (void)textFieldDidChange:(UITextField *)field {
    [self.fetchBlock start];
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
    return indexPath.section != 0;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || ![self hasSuggestedMoves]) return;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
       [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    });
}

- (BOOL)hasSuggestedMoves {
    return !(!self.suggestedMoves || self.fetchError || self.suggestedMoves.count == 0);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return (self.suggestedMoves.count == 0) ? 1 : self.suggestedMoves.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];

        if (!self.nameField) {
            UITextField *field = [[UITextField alloc] init];
            [cell addSubview:field];
            
            [field constrainFlushBottom];
            [field constrainFlushTop];
            [field constrainFlushLeftOffset:12];
            [field constrainFlushRightOffset:12];
            
            field.placeholder = @"Name";
            
            if (self.currentMove.name) field.text = self.currentMove.name;
            
            self.nameField = field;
            [field addTarget:self
                      action:@selector(textFieldDidChange:)
            forControlEvents:UIControlEventEditingChanged];
        }
        
        return cell;
    } else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        
        if (self.fetchError) {
            cell.textLabel.text = @"Error getting suggested moves";
            cell.textLabel.textColor = [UIColor lightGrayColor];
        } else if (self.suggestedMoves == nil) {
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            [cell addSubview:spinner];
            [spinner constrainCenter];
            [spinner startAnimating];
        } else if (self.suggestedMoves.count == 0) {
            cell.textLabel.text = @"No suggested moves found";
            cell.textLabel.textColor = [UIColor lightGrayColor];
        } else {
            cell.textLabel.text = self.suggestedMoves[indexPath.row];
            cell.textLabel.textColor = [UIColor blackColor];
            [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(suggestedMoveTapped:)]];
            cell.tag = indexPath.row;
        }
        
        return cell;
    }
    
    return nil;
}

- (void)suggestedMoveTapped:(UIGestureRecognizer *)tap {
    if (![self hasSuggestedMoves]) return;
    
    self.nameField.text = self.suggestedMoves[tap.view.tag];
    [self loadSuggestedMoves];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Suggested moves";
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section == 1) {
        return @"Moves other users are practicing";
    }
    
    return nil;
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

#pragma mark - loading suggested moves

- (void)loadSuggestedMoves {
    if ([self.nameField.text isEqualToString:@""]) {
        [self loadPopularMoves];
    } else {
        [self loadMovesMatchingTypedName];
    }
}

- (void)loadMovesMatchingTypedName {
    [[API sharedInstance] getMovesMatchingQuery:self.nameField.text completionBlock:^(id moves, NSError *error) {
        if (error) {
            self.fetchError = error;
        } else {
            self.fetchError = nil;
            self.suggestedMoves = moves;
        }
        
        [self reloadSectionWithSuggestedMoves];
    }];
}

- (void)loadPopularMoves {
    [[API sharedInstance] getPopularMoves:^(id moves, NSError *error) {
        if (error) {
            self.fetchError = error;
        } else {
            self.fetchError = nil;
            self.suggestedMoves = moves;
        }
        
        [self reloadSectionWithSuggestedMoves];
    }];
}

- (void)reloadSectionWithSuggestedMoves {
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

@end
