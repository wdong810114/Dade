//
//  Constants.h
//  Dade
//
//  Created by 王冬冬 on 15-1-21.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  常量定义

#define IOS_VERSION_7_OR_ABOVE          (([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) ? (YES) : (NO))
#define IOS_VERSION_8_OR_ABOVE          (([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) ? (YES) : (NO))

#define DEVICE_WIDTH                    [[UIScreen mainScreen] bounds].size.width
#define DEVICE_HEIGHT                   [[UIScreen mainScreen] bounds].size.height
#define STATUS_BAR_HEIGHT               20.0    // 状态栏高度
#define NAVIGATION_BAR_HEIGHT           44.0    // 导航栏高度
#define INPUT_ACCESSORY_VIEW_HEIGHT     44.0    // 键盘附加视图高度
#define TABLEVIEW_CELL_HEIGHT           50.0    // 表视图单元格高度

#define COLOR(R, G, B)                  [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1.0]
#define NAVIGATION_BAR_COLOR            COLOR(0xcf,0x3b,0x1d)   // 导航栏背景颜色
#define TABLEVIEW_BG_COLOR              COLOR(0xff,0xff,0xff)   // 列表视图背景颜色

#define RED_BUTTON_BG_NORMAL_COLOR          COLOR(0xcf,0x3b,0x1d)   // 红色按钮背景颜色（正常）
#define RED_BUTTON_BG_HIGHLIGHTED_COLOR     COLOR(0xba,0x35,0x1a)   // 红色按钮背景颜色（高亮）
#define BLUE_BUTTON_TITLE_NORMAL_COLOR      COLOR(0x21,0x96,0xf3)   // 按钮蓝色标题颜色（正常）
#define BLUE_BUTTON_TITLE_HIGHLIGHTED_COLOR COLOR(0x1a,0x78,0xc2)   // 按钮蓝色标题颜色（高亮）

#define FONT(S)                 [UIFont systemFontOfSize:S]

#define ALERT_BUTTON_TITLE_CONFIRM      @"确定"
#define ALERT_BUTTON_TITLE_CANCEL       @"取消"
#define BAR_BUTTON_TITLE_DONE           @"完成"
