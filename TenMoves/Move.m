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
#import "UpdatedAtObserver.h"

static NSString *ENTITY_NAME = @"Move";

@interface Move ()

@property (strong, nonatomic) UpdatedAtObserver *updatedAtObserver;

@end

@implementation Move

@synthesize updatedAtObserver;

@dynamic createdAt;
@dynamic updatedAt;
@dynamic name;
@dynamic snapshots;

+ (instancetype)newManagedObject {
    return (Move *)[NSEntityDescription insertNewObjectForEntityForName:ENTITY_NAME
                                                 inManagedObjectContext:[Repository managedObjectContext]];
}

+ (NSFetchRequest *)fetchRequest {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:ENTITY_NAME
                                              inManagedObjectContext:[Repository managedObjectContext]];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    fetchRequest.sortDescriptors = @[sortDescriptor];
    
    return fetchRequest;
}

- (void)awakeFromInsert {
    [super awakeFromInsert];

    [self addUpdatedAtObserver];
    
    NSDate *date = [NSDate date];
    self.updatedAt = date;
    self.createdAt = date;
}

- (void)awakeFromFetch {
    [super awakeFromFetch];
    [self addUpdatedAtObserver];
}

- (void)addUpdatedAtObserver {
    if (self.updatedAtObserver) return;
    NSArray *keyPaths = @[@"name", @"snapshots"];
    self.updatedAtObserver = [[UpdatedAtObserver alloc] initWithKeyPaths:keyPaths object:self];
}

@end
