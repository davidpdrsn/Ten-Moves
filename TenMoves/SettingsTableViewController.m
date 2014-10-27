//
//  SettingsTableViewController.m
//  TenMoves
//
//  Created by David Pedersen on 27/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "SettingsTableViewController.h"
#import "Settings.h"

@interface SettingsTableViewController ()

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
    if (indexPath.section != 1) return;
    if (indexPath.row == 0) { [self openWebsite]; }
    if (indexPath.row == 1) { [self openTwitter]; }
}

- (IBAction)openWebsiteButtonTapped:(id)sender {
    [self openWebsite];
}

- (IBAction)openTwitterButtonTapped:(id)sender {
    [self openTwitter];
}

#pragma mark - helpers

- (void)openTwitter {
    NSURL *url = [NSURL URLWithString:@"http://twitter.com/tenmovesapp"];
    [[UIApplication sharedApplication] openURL:url];
}

- (void)openWebsite {
    NSURL *url = [NSURL URLWithString:@"http://tenmoves.net"];
    [[UIApplication sharedApplication] openURL:url];
}

@end
