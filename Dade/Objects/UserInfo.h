//
//  UserInfo.h
//  Dade
//
//  Created by 王冬冬 on 15-2-2.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  用户信息

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject

@property (copy, nonatomic) NSString *staffId;      // 用户ID
@property (copy, nonatomic) NSString *staffPhone;   // 用户电话
@property (copy, nonatomic) NSString *staffSex;     // 性别（1：男，2：女）
@property (copy, nonatomic) NSString *staffMail;    // 邮箱

// 用户企业组织机构信息
@property (copy, nonatomic) NSString *orgId;        // 组织架构ID
@property (copy, nonatomic) NSString *qyId;         // 企业ID
@property (copy, nonatomic) NSString *depId;        // 部门ID
@property (copy, nonatomic) NSString *org;          // 企业名
@property (copy, nonatomic) NSString *dep;          // 部门名
@property (copy, nonatomic) NSString *company;      // 企业名称
@property (copy, nonatomic) NSString *department;   // 部门名称
@property (copy, nonatomic) NSString *depOrgId;     // 部门组织架构ID
@property (copy, nonatomic) NSString *gradeName;    // 级别名称
@property (copy, nonatomic) NSString *gradeId;      // 级别ID
@property (copy, nonatomic) NSString *gradeCode;    // 级别代码
@property (copy, nonatomic) NSString *staffName;    // 级别名称

- (instancetype)initWithDict:(NSDictionary *)dict;
- (void)parseOrganizationDict:(NSDictionary *)dict;

@end

