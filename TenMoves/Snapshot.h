//
//  Snapshot.h
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Move;

@interface Snapshot : NSManagedObject

+ (instancetype)newManagedObject;

+ (NSFetchRequest *)fetchRequestForMove:(Move *)move;

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) Move *move;

@end
