//
//  KIFTestCaseWithCoreData.m
//  TenMoves
//
//  Created by David Pedersen on 27/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "KIFTestCaseWithCoreData.h"
#import "Move.h"

@implementation KIFTestCaseWithCoreData

- (void)setUp {
    [super setUp];

    NSFetchRequest *request = [Move fetchRequest];
    NSManagedObjectContext *moc = [Repository managedObjectContext];
    for (NSManagedObject *obj in [moc executeFetchRequest:request error:nil]) {
        [moc deleteObject:obj];
    }
    [moc save:nil];
}

@end
