//
//  GraphViewController.m
//  TenMoves
//
//  Created by David Pedersen on 26/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "GraphViewController.h"
#import "BEMSimpleLineGraphView.h"
#import "ProgressGraphDataSource.h"
#import "Move.h"
#import "Repository.h"
#import "UIView+Autolayout.h"

@interface GraphViewController ()

@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *graphView;
@property (strong, nonatomic) ProgressGraphDataSource *dataSource;

@end

@implementation GraphViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.dataSource = [[ProgressGraphDataSource alloc] initWithSnapshots:self.move.snapshots];
    self.graphView.dataSource = self.dataSource;
    self.graphView.delegate = self.dataSource;

    self.graphView.colorTop = [UIColor whiteColor];
    self.graphView.colorBottom = [UIColor whiteColor];
    self.graphView.colorLine = self.view.tintColor;
    self.graphView.colorPoint = self.view.tintColor;
    self.graphView.widthLine = 2;
    self.graphView.alphaLine = 1;
    self.graphView.animationGraphEntranceTime = 1;
    self.graphView.enablePopUpReport = NO;
    [self setSizeOfPoint];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadGraph)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:[Repository managedObjectContext]];

    UIView *bottomLine = [[UIView alloc] init];
    [self.view addSubview:bottomLine];
    [bottomLine constrainFlushLeftRight];
    [bottomLine constrainFlushBottomOffset:1];
    [bottomLine constrainHeightToEqual:.5];
    [bottomLine setBackgroundColor:[[UITableView alloc] init].separatorColor];
}

- (void)reloadGraph {
    [self setSizeOfPoint];
    [self.graphView reloadGraph];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.graphView reloadGraph];
}

- (void)setSizeOfPoint {
    if ([self.dataSource numberOfSnapshots] != 1)
        self.graphView.sizePoint = 0;
    else
        self.graphView.sizePoint = 10;
}

@end
