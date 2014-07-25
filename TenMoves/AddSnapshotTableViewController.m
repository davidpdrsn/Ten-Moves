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
#import "Constants.h"
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
    
    [self.improvedProgressView setProgressType:SnapshotProgressImproved];
    [self.improvedProgressView setLabelText:@"Better"];
    [self.improvedProgressView setShowBorder:YES];
    
    [self.sameProgressView setProgressType:SnapshotProgressSame];
    [self.sameProgressView setLabelText:@"Same"];
    [self.sameProgressView setShowBorder:YES];
    
    [self.regressionProgressView setProgressType:SnapshotProgressRegressed];
    [self.regressionProgressView setLabelText:@"Worse"];
    [self.regressionProgressView setShowBorder:NO];
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
