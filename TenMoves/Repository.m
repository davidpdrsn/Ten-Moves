//
//  Repository.m
//  TenMoves
//
//  Created by David Pedersen on 12/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "Repository.h"

static NSManagedObjectContext *_managedObjectContext;

@implementation Repository

+ (NSManagedObjectContext *)managedObjectContext {
    return _managedObjectContext;
}

+ (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext {
    _managedObjectContext = managedObjectContext;
}

+ (void)deleteObject:(id)objectToDelete {
    [_managedObjectContext deleteObject:objectToDelete];
}

+ (void)saveWithCompletionHandler:(CompletionWithPossibleErrorBlock)completionHandler {
    NSError *error;
    [_managedObjectContext save:&error];
    if (completionHandler) completionHandler(error);
}

+ (void)executeFetch:(NSFetchRequest *)request completionBlock:(void (^)(NSArray *results))completion failureBlock:(void (^)(NSError *error))failure {
    [_managedObjectContext performBlock:^{
        NSError *error;
        NSArray *results = [_managedObjectContext executeFetchRequest:request error:&error];
        
        if (error) {
            if (failure) failure(error);
        } else {
            if (completion) completion(results);
        }
    }];
}

@end
