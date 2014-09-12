//
//  UpdatedAtObserver.h
//  TenMoves
//
//  Created by David Pedersen on 12/09/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UpdatedAtObserver : NSObject

- (instancetype)initWithKeyPaths:(NSArray *)keyPaths object:(id)object;

@end
