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

- (void)parseOrganizationArray:(NSArray *)array
{
    NSMutableArray *orgArray = [[NSMutableArray alloc] initWithCapacity:array.count];
    
    for(NSDictionary *dict in array) {
        OrganizationInfo *orgInfo = [[OrganizationInfo alloc] initWithDict:dict];
        [orgArray addObject:orgInfo];

        if(!self.staffName) {
            self.staffName = orgInfo.staffName;
        }
    }
    
    self.organizationArray = [[NSArray alloc] initWithArray:orgArray];
}

@end
