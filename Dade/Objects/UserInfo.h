//
//  UserInfo.h
//  Dade
//
//  Created by 王冬冬 on 15-2-2.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  用户信息

#import <Foundation/Foundation.h>

#import "OrganizationInfo.h"

@interface UserInfo : NSObject

@property (copy, nonatomic) NSString *staffId;              // 用户ID
@property (copy, nonatomic) NSString *staffPhone;           // 用户电话
@property (copy, nonatomic) NSString *staffSex;             // 性别（1：男，2：女）
@property (copy, nonatomic) NSString *staffMail;            // 邮箱
@property (copy, nonatomic) NSString *staffName;            // 人员名称

@property (strong, nonatomic) NSArray *organizationArray;   // 组织机构信息

- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)parseOrganizationArray:(NSArray *)array;

- (NSArray *)allDepartments;

@end

