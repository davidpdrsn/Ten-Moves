//
//  AddSnapshotViewController.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "AddSnapshotViewController.h"

@interface AddSnapshotViewController ()

@end

@implementation AddSnapshotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Add snapshot";
    [self setupNavigationBar];
}

- (void)add {
    [self.delegate addSnapshotViewControllerDidSave];
}

- (void)cancel {
    [self.delegate addSnapshotViewControllerDidCancel:self.currentSnapshot];
}

- (void)setupNavigationBar {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(add)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
}

@end
