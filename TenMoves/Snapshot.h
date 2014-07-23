//
//  Snapshot.h
//  TenMoves
//
//  Created by David Pedersen on 17/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Move;

@interface Snapshot : NSManagedObject

@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * videoPath;
@property (nonatomic, retain) Move *move;

+ (instancetype)newManagedObject;

+ (NSFetchRequest *)fetchRequestForMove:(Move *)move;

- (NSURL *)videoUrl;

@end
