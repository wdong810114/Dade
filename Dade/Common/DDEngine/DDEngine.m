//
//  DDEngine.m
//  Dade
//
//  Created by 王冬冬 on 15-2-2.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "DDEngine.h"

@implementation DDEngine
{
    ASINetworkQueue *_requestQueue;
}

- (void)dealloc
{
    [_requestQueue cancelAllOperations];
}

- (instancetype)init
{
    if(self = [super init]) {
        _requestQueue = [[ASINetworkQueue alloc] init];
        _requestQueue.shouldCancelAllRequestsOnFailure = NO;
        [_requestQueue go];
    }
    
    return self;
}

- (void)appendHttpRequest:(ASIHTTPRequest *)request delegate:(id)delegate didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector
{
    request.allowCompressedResponse = YES;
    request.numberOfTimesToRetryOnTimeout = 1;
    request.delegate = delegate;
    request.didFinishSelector = didFinishSelector;
    request.didFailSelector = didFailSelector;
    [_requestQueue addOperation:request];
}

@end
