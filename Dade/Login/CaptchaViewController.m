//
//  CaptchaViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-23.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "CaptchaViewController.h"

@interface CaptchaViewController ()

- (void)initView;
- (BOOL)checkValidity;
- (void)login;

@end

@implementation CaptchaViewController

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
    
    [self setNavigationBarTitle:@"短信验证码"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

- (IBAction)loginButtonClicked:(UIButton *)button
{
    // 登录
    
    [self login];
}

#pragma mark - Private Methods
- (void)initView
{
    [self.loginButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.loginButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (BOOL)checkValidity
{
    return YES;
}

- (void)login
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        [DadeAppDelegate loginSuccessed];
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
    
    if(textField == self.captchaTextField) {
        if(toBeString.length > 6) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.captchaTextField) {
        [self.captchaTextField resignFirstResponder];
        [self login];
    }
    
    return YES;
}

@end
