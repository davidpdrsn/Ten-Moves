//
//  VideoPicker.h
//  TenMoves
//
//  Created by David Pedersen on 28/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VideoPicker;

@protocol VideoPickerDelegate <NSObject>

- (void)videoPicker:(VideoPicker *)picker didPickVideoAtUrl:(NSURL *)url;

@end

@interface VideoPicker : NSObject

- (instancetype)initWithDelegate:(UIViewController<VideoPickerDelegate> *) delegate;

- (void)startBrowsingForType:(UIImagePickerControllerSourceType)type;

@end
