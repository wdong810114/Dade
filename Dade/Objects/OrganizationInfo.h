//
//  OrganizationInfo.h
//  Dade
//
//  Created by 王冬冬 on 15-4-16.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  组织信息

#import <Foundation/Foundation.h>

@interface OrganizationInfo : NSObject

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
@property (copy, nonatomic) NSString *staffName;    // 人员名称

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
