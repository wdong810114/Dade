//
//  LoginViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-23.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "LoginViewController.h"

#import "CaptchaViewController.h"

@interface LoginViewController ()

- (NSString *)randomCode;

- (void)initView;
- (BOOL)checkValidity;
- (void)login;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"登录"];
}

- (IBAction)loginButtonClicked:(UIButton *)button
{
    // 登录
    
    [self login];
}

#pragma mark - Private Methods
- (NSString *)randomCode
{
    int code = (arc4random() % 9000) + 1000;
    
    return [NSString stringWithFormat:@"%i", code];
}

- (void)initView
{
    self.usernameImageView.image = [UIImage imageNamed:@"username_icon"];
    self.passwordImageView.image = [UIImage imageNamed:@"password_icon"];
    
    [self.loginButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.codeLabel.text = [self randomCode];
}

- (BOOL)checkValidity
{
//    if([[Util trimString:self.usernameTextField.text] isEqualToString:@""] ||
//       [[Util trimString:self.passwordTextField.text] isEqualToString:@""] ||
//       [[Util trimString:self.codeTextField.text] isEqualToString:@""]) {
//        [self showAlert:@"信息填写不完整"];
//        
//        return NO;
//    }
//    
//    if(![self.codeTextField.text isEqualToString:self.codeLabel.text]) {
//        [self showAlert:@"验证码错误"];
//        
//        return NO;
//    }
    
    return YES;
}

- (void)login
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        CaptchaViewController *viewController = [[CaptchaViewController alloc] initWithNibName:@"CaptchaViewController" bundle:nil];
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    
    if(textField == self.codeTextField) {
        if(toBeString.length > 4) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.usernameTextField) {
        [self.usernameTextField resignFirstResponder];
        [self.passwordTextField becomeFirstResponder];
    } else if(textField == self.passwordTextField) {
        [self.passwordTextField resignFirstResponder];
        [self.codeTextField becomeFirstResponder];
    } else {
        [self.codeTextField resignFirstResponder];
        [self login];
    }
    
    return YES;
}

@end
