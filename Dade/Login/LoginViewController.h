//
//  LoginViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-23.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  登录页

#import "BaseViewController.h"

@interface LoginViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *usernameImageView;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UIImageView *passwordImageView;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonClicked:(UIButton *)button;

@end
