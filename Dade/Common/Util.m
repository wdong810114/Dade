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
