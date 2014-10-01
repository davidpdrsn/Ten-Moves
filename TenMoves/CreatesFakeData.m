//
//  CreatesFakeData.m
//  TenMoves
//
//  Created by David Pedersen on 01/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "CreatesFakeData.h"
#import "Move.h"
#import "Snapshot.h"
#import "Repository.h"

@implementation CreatesFakeData

+ (void)makeFakeMovesAndSnapshots {
    NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSURL *documentsURL = [NSURL fileURLWithPath:documentsPath];
    NSLog(@"%@", documentsURL);

    // Delete all moves
    NSManagedObjectContext *moc = [Repository managedObjectContext];
    for (Move *move in [moc executeFetchRequest:[Move fetchRequest] error:nil]) {
        [Repository deleteObject:move];
    }

    NSArray *moves = @[
                       @"Cascade",
                       @"Goliath",
                       @"Jackson 5",
                       @"Meridian",
                       @"Pandora",
                       @"Sybil",
                       @"That Big Thing",
                       @"Waterwheel"
                       ];

    for (NSString *name in moves) {
        Move *move = [Move newManagedObject];
        move.name = name;

        NSArray *snaps = @[
                           @"IMG_0588.MOV",
                           @"IMG_0580.MOV",
                           @"IMG_0553.MOV",
                           @"IMG_0549.MOV",
                           @"IMG_0406.MOV",
                           @"IMG_0404.MOV",
                           @"IMG_0342.MOV",
                           @"IMG_0258.MOV",
                           @"IMG_0257.MOV",
                           @"IMG_0256.MOV",
                           @"IMG_0168.MOV"
                           ];

        int random = arc4random();

        for (NSUInteger i = 0; i < random%snaps.count; i++) {
            NSString *file = (NSString *)snaps[i];
            NSURL *fullUrl = [documentsURL URLByAppendingPathComponent:file];
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:fullUrl.path]) {
                int random2 = arc4random();
                Snapshot *snap = [Snapshot newManagedObject];
                snap.move = move;
                
                if (random2 % 2 == 0) {
                    [snap setProgressTypeRaw:SnapshotProgressImproved];
                } else if (random2 % 3  == 0) {
                    [snap setProgressTypeRaw:SnapshotProgressRegressed];
                } else {
                    [snap setProgressTypeRaw:SnapshotProgressSame];
                }
                
                [snap saveVideoAtFileUrl:fullUrl completionBlock:^{} failureBlock:^(NSError *error) {}];
            }
        }
    }

    [Repository saveWithCompletionHandler:nil];
}

@end
