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

- (void)parseOrganizationDict:(NSDictionary *)dict
{
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

@end
