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

@property (strong, nonatomic) IBOutlet RatingView *ratingView;

@end

@implementation AddSnapshotViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Add snapshot";
    [self setupNavigationBar];
    
    self.ratingView = [self.ratingView initWithFrame:self.ratingView.frame numberOfStars:5 fontSize:25];
    self.ratingView.tintColor = self.view.tintColor;
    self.ratingView.userInteractionEnabled = YES;
    self.ratingView.delegate = self;
    [self.ratingView selectStars:self.currentSnapshot.rating.intValue];
}

- (void)ratingView:(RatingView *)ratingView ratingDidChangeTo:(NSUInteger)stars outOf:(NSUInteger)totalNumberOfStars {
    self.currentSnapshot.rating = [NSNumber numberWithInt:(int)stars];
}

- (void)add {
    [self.delegate addSnapshotViewControllerDidSave];
}

- (void)cancel {
    [self.delegate addSnapshotViewControllerDidCancel:self.currentSnapshot];
}

- (void)setupNavigationBar {
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(add)];
    addButton.tintColor = self.view.tintColor;
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel)];
    cancelButton.tintColor = self.view.tintColor;
    self.navigationItem.leftBarButtonItem = cancelButton;
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
