//
//  UITableViewCell+HelperMethods.m
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "UITableViewCell+HelperMethods.h"
#import "ALAssetsLibrary+HelperMethods.h"
@import AssetsLibrary;

@implementation UITableViewCell (HelperMethods)

- (void)setImageWithAssetUrl:(NSURL *)url {
    [self setImageWithAssetUrl:url forKeyPath:@"imageView.image"];
}

- (void)setImageWithAssetUrl:(NSURL *)url forKeyPath:(NSString *)keyPath {
    [ALAssetsLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
        UIImage *image = [UIImage imageWithCGImage:asset.thumbnail];
        [self setValue:image forKey:keyPath];
        [self setNeedsLayout];
    } failureBlock:^(NSError *error) {
        NSLog(@"Image not found");
    }];
}

@end
