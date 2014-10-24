//
//  API.m
//  TenMoves
//
//  Created by David Pedersen on 24/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "API.h"
#import "AFNetworking/AFNetworking.h"

@interface API ()

@property (strong, nonatomic) NSString *apiBase;
@property (strong, nonatomic) NSString *apiKey;

@end

@implementation API

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static API * sharedInstance;
    dispatch_once(&once, ^ { sharedInstance = [[self alloc] init]; });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
#ifdef DEBUG
        _apiBase = @"http://tenmoves-api.dev";
#else
        _apiBase = @"http://tenmovesapi.herokuapp.com";
#endif
        _apiKey = @"027b311dc95c1613a2d05e99b7d6bd4079b7414c";
    }
    return self;
}

- (void)getMoves:(void (^)(id moves, NSError *error))completionBlock {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager GET:[self.apiBase stringByAppendingPathComponent:@"moves"]
      parameters:[self makeParams:nil]
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
        completionBlock(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
}

- (NSDictionary *)makeParams:(NSDictionary *)params {
    NSMutableDictionary *allParams = [@{ @"api_key": self.apiKey } mutableCopy];
    if (params) {
        [allParams addEntriesFromDictionary:params];
    }
    return [NSDictionary dictionaryWithDictionary:allParams];
}

@end
