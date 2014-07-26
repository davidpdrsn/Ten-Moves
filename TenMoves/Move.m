//
//  Move.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "Move.h"
#import "Snapshot.h"
#import "Repository.h"

static NSString *ENTITY_NAME = @"Move";

@implementation Move

@dynamic createdAt;
@dynamic updatedAt;
@dynamic name;
@dynamic snapshots;

+ (instancetype)newManagedObject {
    Move *move = (Move *) [NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                        inManagedObjectContext:[Repository managedObjectContext]];
    
    return move;
}

+ (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME inManagedObjectContext:[Repository managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    return fetchRequest;
}

@end
