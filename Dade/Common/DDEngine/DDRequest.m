//
//  DDRequest.m
//  Dade
//
//  Created by 王冬冬 on 15-2-10.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "DDRequest.h"

@implementation DDRequest

- (void)dealloc
{
    [self.request clearDelegatesAndCancel];
}

@end
