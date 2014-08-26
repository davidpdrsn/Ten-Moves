//
//  VideoEditor.h
//  TenMoves
//
//  Created by David Pedersen on 29/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoEditor : NSObject

- (void)trimVideoAtUrl:(NSURL *)url
                 start:(NSNumber *)start
                   end:(NSNumber *)end
       completionBlock:(void (^)(NSURL *urlOfTrimmedVideo))completionHandler
          failureBlock:(void (^)(NSError *error))failureBlock;

- (UIImage*)thumbnailForVideoAtUrl:(NSURL *)url;

@end
