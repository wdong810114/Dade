//
//  AppDelegate.h
//  Dade
//
//  Created by 王冬冬 on 15-1-21.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DDEngine.h"
#import "UserInfo.h"

#define DadeAppDelegate     ((AppDelegate *)[[UIApplication sharedApplication] delegate])
#define DadeAppVersion      ([[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"])

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *mainNavigationController;
@property (strong, nonatomic) UINavigationController *loginNavigationController;

@property (strong, nonatomic) DDEngine *engine;
@property (strong, nonatomic) UserInfo *userInfo;

- (void)loginSuccessed;

@end

