//
//  UITableViewCell+HelperMethods.m
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "UITableViewCell+HelperMethods.h"
@import AssetsLibrary;

@implementation UITableViewCell (HelperMethods)

- (void)setImageWithAssetUrl:(NSURL *)url {
    ALAssetsLibrary* library = [[ALAssetsLibrary alloc] init];
    
    [library assetForURL:url resultBlock:^(ALAsset *asset) {
        UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
        self.imageView.image = image;
        [self setNeedsLayout];
    } failureBlock:^(NSError *error) {
        NSLog(@"Image not found");
    }];
}

@end
