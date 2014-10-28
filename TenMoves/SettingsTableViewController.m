//
//  SettingsTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 27/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Settings.h"
#import <MessageUI/MessageUI.h>

@interface SettingsTableViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UISwitch *shareMovesWithAPISwitch;
@property (strong, nonatomic) Settings *settings;

@end

@implementation SettingsTableViewController

#pragma mark - view life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settings = [Settings sharedInstance];
    [self.shareMovesWithAPISwitch setOn:self.settings.shareMovesWithAPI
                               animated:NO];
}

#pragma mark - responding to interface events

- (IBAction)switchChanged:(UISwitch *)sender {
    self.settings.shareMovesWithAPI = [sender isOn];
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) { [self openWebsite]; }
        if (indexPath.row == 1) { [self openTwitter]; }
    }
    
    if (indexPath.section == 2 && indexPath.row == 0) {
        [self openFeedbackEmailComposer];
    }
    
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
}

- (IBAction)openWebsiteButtonTapped:(id)sender {
    [self openWebsite];
}

- (IBAction)openTwitterButtonTapped:(id)sender {
    [self openTwitter];
}

#pragma mark - helpers

- (void)openFeedbackEmailComposer {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.subject = @"Feedback for Ten Moves";
        [mail setToRecipients:@[@"feedback@tenmoves.net"]];
        mail.mailComposeDelegate = self;
        mail.view.tintColor = self.view.tintColor;
        
        [self presentViewController:mail animated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot send email" message:nil delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)openTwitter {
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/tenmovesapp"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)openWebsite {
    NSURL *url = [NSURL URLWithString:@"http://tenmoves.net"];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - mail composer delegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
