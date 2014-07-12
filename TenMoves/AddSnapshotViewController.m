//
//  AddSnapshotViewController.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "AddSnapshotViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>

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
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = delegate;
    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

@end
