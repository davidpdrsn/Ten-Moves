//
//  API.m
//  TenMoves
//
//  Created by David Pedersen on 24/10/14.
//  Copyright (c) 2014 David Pedersen. All rights reserved.
//

#import "API.h"
#import "AFNetworking/AFNetworking.h"
#import "Settings.h"

@interface API ()

@property (strong, nonatomic) NSString *apiBase;
@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;

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
        _manager = [AFHTTPRequestOperationManager manager];
    }
    return self;
}

#pragma mark - main api methods

- (void)getMoves:(void (^)(id moves, NSError *error))completionBlock {
    [self.manager GET:[self.apiBase stringByAppendingPathComponent:@"moves"]
      parameters:[self makeParams:nil]
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             
        completionBlock(responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(nil, error);
    }];
}

- (void)addMove:(NSString *)name completion:(void (^)(NSError *error))completionBlock {
    if (![Settings sharedInstance].shareMovesWithAPI) { return; }
    
    [self.manager POST:[self.apiBase stringByAppendingPathComponent:@"moves"]
            parameters:[self makeParams:@{ @"move": @{ @"name": name } }]
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(error);
    }];
}

- (void)deleteMove:(NSString *)name completion:(void (^)(NSError *))completionBlock {
    if (![Settings sharedInstance].shareMovesWithAPI) { return; }
    
    [self.manager DELETE:[self.apiBase stringByAppendingPathComponent:@"delete_move_by_name"] parameters:[self makeParams:@{ @"name": name }] success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completionBlock(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        completionBlock(error);
    }];
}

#pragma mark - helpers

- (NSDictionary *)makeParams:(NSDictionary *)params {
    NSMutableDictionary *allParams = [@{
                                        @"api_key": self.apiKey
                                        } mutableCopy];
    if (params) {
        [allParams addEntriesFromDictionary:params];
    }
    return [NSDictionary dictionaryWithDictionary:allParams];
}

@end
