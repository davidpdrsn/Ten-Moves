//
//  Move.m
//  TenMoves
//
//  Created by David Pedersen on 11/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "Move.h"
#import "Snapshot.h"


@implementation Move

@dynamic createdAt;
@dynamic name;
@dynamic snapshots;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    [self setValue:[NSDate date] forKey:@"createdAt"];
}

@end
