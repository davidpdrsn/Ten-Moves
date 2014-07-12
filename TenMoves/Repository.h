//
//  Repository.h
//  TenMoves
//
//  Created by David Pedersen on 12/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Repository : NSObject

+ (NSManagedObjectContext *)managedObjectContext;
+ (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (void)deleteObject:(id)objectToDelete;

+ (void)saveWithCompletionHandler:(void (^)(NSError *error))completionHandler;

@end
