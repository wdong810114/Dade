//
//  DDRequest.h
//  Dade
//
//  Created by 王冬冬 on 15-2-10.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ASIHTTPRequest.h"

@interface DDRequest : NSObject

@property (weak, nonatomic) ASIHTTPRequest *request;
@property (assign, nonatomic) SEL didFinishSelector;
@property (assign, nonatomic) SEL didFailSelector;

@end
