//
//  OrganizationInfo.m
//  Dade
//
//  Created by 王冬冬 on 15-4-16.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "OrganizationInfo.h"

#import "NSDictionary+Util.h"

@implementation OrganizationInfo

- (instancetype)initWithDict:(NSDictionary *)dict
{
    self = [super init];
    if(self) {
        self.orgId = [dict stringForKey:@"org_id"];
        self.qyId = [dict stringForKey:@"qyid"];
        self.depId = [dict stringForKey:@"depid"];
        self.org = [dict stringForKey:@"org"];
        self.dep = [dict stringForKey:@"dep"];
        self.company = [dict stringForKey:@"company"];
        self.department = [dict stringForKey:@"department"];
        self.depOrgId = [dict stringForKey:@"depOrgid"];
        self.gradeName = [dict stringForKey:@"gradenm"];
        self.gradeId = [dict stringForKey:@"gradeid"];
        self.gradeCode = [dict stringForKey:@"grade_code"];
        self.staffName = [dict stringForKey:@"staffname"];
    }
    
    return self;
}

@end
