//
//  ArrayDataSourceDelegate.h
//  TenMoves
//
//  Created by David Pedersen on 23/07/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ArrayDataSource;

@protocol ArrayDataSourceDelegate

@required
@optional

- (NSString *)arrayDataSource:(ArrayDataSource *)arrayDataSource textForFooterView:(NSArray *)objects;

- (void)arrayDataSourceDidChangeData:(ArrayDataSource *)arrayDataSource;

@end

