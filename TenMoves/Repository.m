//
//  Repository.m
//  TenMoves
//
//  Created by David Pedersen on 12/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "Repository.h"
#import "ModelObjectWithTimeStamps.h"

static NSManagedObjectContext *_managedObjectContext;

@implementation Repository

+ (NSManagedObjectContext *)managedObjectContext {
    return _managedObjectContext;
}

+ (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contextWillSave:)
                                                 name:NSManagedObjectContextWillSaveNotification
                                               object:_managedObjectContext];
}

+ (void)deleteObject:(id)objectToDelete {
    [_managedObjectContext deleteObject:objectToDelete];
}

+ (void)saveWithCompletionHandler:(CompletionWithPossibleErrorBlock)completionHandler {
    NSError *error;
    [_managedObjectContext save:&error];
    completionHandler(error);
}

+ (void)contextWillSave:(NSNotification *)notification {
    NSManagedObjectContext *context = [notification object];
    
    NSDate *now = [NSDate date];
    
    for (NSManagedObject *obj in [context insertedObjects]) {
        if ([obj conformsToProtocol:@protocol(ModelObjectWithTimeStamps)]) {
            [obj setValue:now forKey:@"createdAt"];
            [obj setValue:now forKey:@"updatedAt"];
        }
    }
    
    for (NSManagedObject *obj in [context updatedObjects]) {
        if ([obj conformsToProtocol:@protocol(ModelObjectWithTimeStamps)]) {
            [obj setValue:now forKey:@"updatedAt"];
        }
    }
}

@end
