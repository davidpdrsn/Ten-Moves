//
//  AddSnapshotViewController.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "AddSnapshotTableViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "Snapshot.h"
#import "ProgressPickerButton.h"

@interface AddSnapshotTableViewController ()

@property (weak, nonatomic) IBOutlet UITableViewCell *progressCell;

@property (weak, nonatomic) IBOutlet ProgressPickerButton *improvedProgressView;
@property (weak, nonatomic) IBOutlet ProgressPickerButton *sameProgressView;
@property (weak, nonatomic) IBOutlet ProgressPickerButton *regressionProgressView;

@end

@implementation AddSnapshotTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    for (ProgressPickerButton *progressView in @[self.improvedProgressView,
                                         self.sameProgressView,
                                         self.regressionProgressView]) {
        [progressView resizeToFit:self.progressCell.frame];
        progressView.backgroundColor = [UIColor clearColor];
    }
    
    [self addCircleToProgressView:self.improvedProgressView withColor:[UIColor greenColor]];
    [self addLabelToProgressView:self.improvedProgressView withText:@"Better"];
    
    [self addCircleToProgressView:self.sameProgressView withColor:[UIColor yellowColor]];
    [self addLabelToProgressView:self.sameProgressView withText:@"Same"];

    [self addCircleToProgressView:self.regressionProgressView withColor:[UIColor redColor]];
    [self addLabelToProgressView:self.regressionProgressView withText:@"Worse"];
    
    for (ProgressPickerButton *progressView in @[self.improvedProgressView,
                                         self.sameProgressView]) {
        CALayer *rightBorder = [CALayer layer];
        rightBorder.frame = CGRectMake(progressView.frame.size.width, 0, 0.5f, self.progressCell.frame.size.height);
        rightBorder.backgroundColor = [[UITableView alloc] init].separatorColor.CGColor;
        [progressView.layer addSublayer:rightBorder];
    }
}

- (void)addLabelToProgressView:(ProgressPickerButton *)progressView withText:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    label.font = [UIFont systemFontOfSize:12];
    [label sizeToFit];
    label.frame = CGRectMake(0,
                             progressView.frame.size.height - label.frame.size.height - 7,
                             progressView.frame.size.width,
                             label.frame.size.height);
    [progressView addSubview:label];
}

- (void)addCircleToProgressView:(ProgressPickerButton *)progressView withColor:(UIColor *)color {
    CGFloat size = progressView.frame.size.height/2;
    CGRect frame = CGRectMake(progressView.frame.size.width/2 - size/2,
                              progressView.frame.size.height/2 - size/2 - 7,
                              size,
                              size);
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.backgroundColor = color;
    imageView.layer.cornerRadius = size/2;
    [progressView addSubview:imageView];
}

- (void)progressViewTapped:(ProgressPickerButton *)progressView {
    if (progressView == self.improvedProgressView) {
        NSLog(@"improved");
    } else if (progressView == self.sameProgressView) {
        NSLog(@"same");
    } else if (progressView == self.regressionProgressView) {
        NSLog(@"regression");
    }
}

- (void)add {
    [self.delegate addSnapshotTableViewControllerDidSave];
}

- (IBAction)cancel:(id)sender {
    [self.delegate addSnapshotTableViewControllerDidCancel:self.currentSnapshot];
}

- (IBAction)done:(id)sender {
    [self add];
}

- (IBAction)pickPhoto:(id)sender {
    [self startMediaBrowserFromViewController:self usingDelegate:self];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
    self.currentSnapshot.videoPath = [url absoluteString];
}

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {
    UIImagePickerControllerSourceType type = UIImagePickerControllerSourceTypePhotoLibrary;
    
    if (([UIImagePickerController isSourceTypeAvailable: type] == NO)
        || (delegate == nil)
        || (controller == nil)) {
        return NO;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = type;
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    mediaUI.allowsEditing = YES;
    mediaUI.delegate = delegate;
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

@end
