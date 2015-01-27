//
//  CaptchaViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-23.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  输入验证码页

#import "BaseViewController.h"

@interface CaptchaViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextField *captchaTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonClicked:(UIButton *)button;

@end
