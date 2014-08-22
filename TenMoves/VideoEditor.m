//
//  VideoEditor.m
//  TenMoves
//
//  Created by David Pedersen on 29/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "VideoEditor.h"
@import AVFoundation;

@implementation VideoEditor

- (void)trimVideoAtUrl:(NSURL *)url
                 start:(NSNumber *)start
                   end:(NSNumber *)end
       completionBlock:(void (^)(NSURL *urlOfTrimmedVideo))completionBlock
          failureBlock:(void (^)(NSError *error))failureBlock {

    int startMilliseconds = ([start doubleValue] * 1000);
    int endMilliseconds = ([end doubleValue] * 1000);
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSString *outputURL = [documentsDirectory stringByAppendingPathComponent:@"output"] ;
    [manager createDirectoryAtPath:outputURL withIntermediateDirectories:YES attributes:nil error:nil];
    
    outputURL = [outputURL stringByAppendingPathComponent:@"output.mp4"];
    [manager removeItemAtPath:outputURL error:nil];
    
    AVURLAsset *videoAsset = [AVURLAsset URLAssetWithURL:url options:nil];
    
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:videoAsset presetName:AVAssetExportPresetPassthrough];
    exportSession.outputURL = [NSURL fileURLWithPath:outputURL];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    CMTimeRange timeRange = CMTimeRangeMake(CMTimeMake(startMilliseconds, 1000), CMTimeMake(endMilliseconds - startMilliseconds, 1000));
    exportSession.timeRange = timeRange;
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        switch (exportSession.status) {
            case AVAssetExportSessionStatusCompleted: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(exportSession.outputURL);
                });
            }
                break;
            default: {
                dispatch_async(dispatch_get_main_queue(), ^{
                    failureBlock(exportSession.error);
                });
            }
                break;
        }
    }];
}

@end
