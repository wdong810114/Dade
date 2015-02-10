//
//  Util.h
//  Dade
//
//  Created by 王冬冬 on 15-1-21.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface Util : NSObject

+ (NSString *)trimString:(NSString *)string;
+ (BOOL)isEmptyString:(NSString *)string;

+ (CGSize)sizeOfString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)size;
+ (CGSize)sizeOfString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode;

@end

@interface Util (Image)

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
