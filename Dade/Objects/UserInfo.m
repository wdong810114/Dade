//
//  UserInfo.m
//  Dade
//
//  Created by 王冬冬 on 15-2-2.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "UserInfo.h"

@implementation UserInfo

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        self.staffId = [dict objectForKey:@"staffId"];
        self.staffPhone = [dict objectForKey:@"staffPhone"];
        self.staffSex = [dict objectForKey:@"staffSex"];
        self.staffMail = [dict objectForKey:@"staffMail"];
    }
    
    return self;
}

@end
