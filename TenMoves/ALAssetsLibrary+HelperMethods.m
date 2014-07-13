//
//  ALAssetsLibrary+HelperMethods.m
//  TenMoves
//
//  Created by David Pedersen on 13/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "ALAssetsLibrary+HelperMethods.h"

@implementation ALAssetsLibrary (HelperMethods)

+ (void)assetForURL:(NSURL *)assetURL resultBlock:(ALAssetsLibraryAssetForURLResultBlock)resultBlock failureBlock:(ALAssetsLibraryAccessFailureBlock)failureBlock {
    ALAssetsLibrary *lib = [[self alloc] init];
    
    [lib assetForURL:assetURL resultBlock:^(ALAsset *asset) {
        if (asset) {
            resultBlock(asset);
        } else {
            NSError *error;
            failureBlock(error);
        }
    } failureBlock:failureBlock];
}

@end
