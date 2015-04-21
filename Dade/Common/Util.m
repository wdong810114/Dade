//
//  Util.m
//  Dade
//
//  Created by 王冬冬 on 15-1-21.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (NSString *)trimString:(NSString *)string
{
    if(string == nil) {
        return @"";
    }
    
    NSString *trimmedString = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return trimmedString;
}

+ (BOOL)isEmptyString:(NSString *)string
{
    if(!string) {
        return YES;
    }
    
    return string.length == 0;
}

+ (BOOL)isValidDate:(NSString *)dateString
{
    NSString *regex = @"^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject:dateString];
}

+ (BOOL)isValidNumber:(NSString *)numberString
{
    NSScanner *scanner = [NSScanner scannerWithString:numberString];
    NSInteger val;
    return [scanner scanInteger:&val] && [scanner isAtEnd];
}

+ (BOOL)isValidScore:(NSString *)scoreString
{
    NSString *regex = @"^(?:0|[1-9][0-9]?|100)$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [predicate evaluateWithObject:scoreString];
}

+ (CGSize)sizeOfString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)size
{
    return [Util sizeOfString:string
                         font:font
            constrainedToSize:size
                lineBreakMode:NSLineBreakByTruncatingTail];
}

+ (CGSize)sizeOfString:(NSString *)string font:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode
{
    CGSize expectedSize = CGSizeZero;
    
    if([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = lineBreakMode;
        NSDictionary *attributes = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        expectedSize = [string boundingRectWithSize:size
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:attributes
                                            context:nil].size;
    } else {
        expectedSize = [string sizeWithFont:font
                          constrainedToSize:size
                              lineBreakMode:lineBreakMode];
    }
    
    return CGSizeMake(ceil(expectedSize.width), ceil(expectedSize.height));
}

@end

@implementation Util (Image)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0, 0.0, 1.0, 1.0);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
