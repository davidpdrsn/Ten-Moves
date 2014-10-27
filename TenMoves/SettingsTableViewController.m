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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.settings = [Settings sharedInstance];
    [self.shareMovesWithAPISwitch setOn:self.settings.shareMovesWithAPI
                               animated:NO];
}

- (IBAction)switchChanged:(UISwitch *)sender {
    self.settings.shareMovesWithAPI = [sender isOn];
}

@end
