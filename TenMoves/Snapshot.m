//
//  Snapshot.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "Snapshot.h"
#import "Move.h"


@implementation Snapshot

@dynamic createdAt;
@dynamic move;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    [self setValue:[NSDate date] forKey:@"createdAt"];
}

@end
