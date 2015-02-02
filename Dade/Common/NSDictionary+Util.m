//
//  NSDictionary+Util.m
//  Dade
//
//  Created by 王冬冬 on 15-2-2.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "NSDictionary+Util.h"

@implementation NSDictionary (Util)

- (NSString *)stringForKey:(id)key
{
    if(self == nil) {
        return @"";
    }
    
    id value = [self objectForKey:key];
    if(!value || [value isKindOfClass:[NSNull class]]) {
        return @"";
    }
    
    if([value isKindOfClass:[NSString class]]) {
        return value;
    }
    
    if([value isKindOfClass:[NSNumber class]]) {
        return ((NSNumber *)value).stringValue;
    }
    
    return @"";
}

@end
