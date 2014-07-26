//
//  ModelObjectWithTimeStamps.h
//  TenMoves
//
//  Created by David Pedersen on 26/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ModelObjectWithTimeStamps

- (NSDate *)updatedAt;
- (void)setUpdatedAt:(NSDate *)date;

- (NSDate *)createdAt;
- (void)setCreatedAt:(NSDate *)date;

@end