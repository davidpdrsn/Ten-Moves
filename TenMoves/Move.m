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

static NSString *entityName = @"Move";

@implementation Move

@dynamic createdAt;
@dynamic name;
@dynamic snapshots;

+ (instancetype)newManagedObject {
    Move *move = (Move *) [NSEntityDescription insertNewObjectForEntityForName:entityName
                                                        inManagedObjectContext:[Repository managedObjectContext]];
    
    return move;
}

+ (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityName inManagedObjectContext:[Repository managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    return fetchRequest;
}

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [self setValue:[NSDate date] forKey:@"createdAt"];
}

@end
