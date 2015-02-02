//
//  DDEngine.h
//  Dade
//
//  Created by 王冬冬 on 15-2-2.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"
#import "ASINetworkQueue.h"

@interface DDEngine : NSObject

- (void)appendHttpRequest:(ASIHTTPRequest *)request delegate:(id)delegate didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;

@end
