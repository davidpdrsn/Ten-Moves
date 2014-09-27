//
//  Repository.h
//  TenMoves
//
//  Created by David Pedersen on 12/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSFetchRequest;

typedef void (^CompletionWithPossibleErrorBlock)(NSError *);

@interface Repository : NSObject

+ (NSManagedObjectContext *)managedObjectContext;
+ (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)deleteObject:(id)objectToDelete;

+ (void)saveWithCompletionHandler:(CompletionWithPossibleErrorBlock)completionHandler;

+ (void)executeFetch:(NSFetchRequest *)request completionBlock:(void (^)(NSArray *results))completion failureBlock:(void (^)(NSError *error))failure;

@end
