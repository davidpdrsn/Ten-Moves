//
//  VideoPicker.m
//  TenMoves
//
//  Created by David Pedersen on 28/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "VideoPicker.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "VideoEditor.h"

@interface VideoPicker () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (strong, nonatomic) UIViewController<VideoPickerDelegate> *delegate;

@end

@implementation VideoPicker

- (instancetype)initWithDelegate:(UIViewController<VideoPickerDelegate> *)delegate {
    self = [super init];
    if (!self) {
        return nil;
    }

    _delegate = delegate;

    return self;

}

- (void)startBrowsingForType:(UIImagePickerControllerSourceType)type {
    if ([UIImagePickerController isSourceTypeAvailable: type] && self.delegate) {
        UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
        mediaUI.sourceType = type;
        mediaUI.mediaTypes = @[(NSString *)kUTTypeMovie];
        mediaUI.allowsEditing = YES;
        mediaUI.delegate = self;
        [self.delegate presentViewController:mediaUI animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Video recording not supported"
                                    message:@"Your phone does not support video recording"
                                   delegate:nil
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:nil] show];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *mediaUrl = info[UIImagePickerControllerMediaURL];
    
    BOOL videoWasEdited = info[@"_UIImagePickerControllerVideoEditingStart"] && info[@"_UIImagePickerControllerVideoEditingEnd"];
    if (videoWasEdited) {
        NSNumber *start = [info objectForKey:@"_UIImagePickerControllerVideoEditingStart"];
        NSNumber *end = [info objectForKey:@"_UIImagePickerControllerVideoEditingEnd"];
        
        VideoEditor *editor = [[VideoEditor alloc] init];
        [editor trimVideoAtUrl:mediaUrl start:start end:end completionBlock:^(NSURL *urlOfTrimmedVideo) {
            [self.delegate videoPicker:self didPickVideoAtUrl:urlOfTrimmedVideo];
        } failureBlock:^(NSError *error) {
            [self showVideoCopyAlert];
        }];
    } else {
        [self.delegate videoPicker:self didPickVideoAtUrl:mediaUrl];
    }
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)showVideoCopyAlert {
    [[[UIAlertView alloc] initWithTitle:@"Failed importing video"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"Okay"
                      otherButtonTitles:nil] show];
}

@end
