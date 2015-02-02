//
//  UserInfo.m
//  Dade
//
//  Created by 王冬冬 on 15-2-2.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "UserInfo.h"

#import "NSDictionary+Util.h"

@implementation UserInfo

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        self.staffId = [dict stringForKey:@"staffId"];
        self.staffPhone = [dict stringForKey:@"staffPhone"];
        self.staffSex = [dict stringForKey:@"staffSex"];
        self.staffMail = [dict stringForKey:@"staffMail"];
    }
    
    return self;
}

@end
