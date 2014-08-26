//
//  NSDate+Helpers.m
//  TenMoves
//
//  Created by David Pedersen on 26/08/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "NSDate+Helpers.h"

@implementation NSDate (Helpers)

- (NSString *)daySuffix {
    NSInteger day_of_month = [[[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:self] day];
    switch (day_of_month) {
        case 1:
        case 21:
        case 31: return @"st";
        case 2:
        case 22: return @"nd";
        case 3:
        case 23: return @"rd";
        default: return @"th";
    }
}

@end
