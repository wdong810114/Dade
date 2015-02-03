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
- (void)requestLoginFinished:(ASIHTTPRequest *)request;
- (void)requestLoginFailed:(ASIHTTPRequest *)request;

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
    
    if([self isRequesting]) {
        return;
    }
    
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
    
// 测试---Start
    self.usernameTextField.text = @"lus";
    self.passwordTextField.text = @"123456";
    self.codeTextField.text = @"9999";
    self.codeLabel.text = @"9999";
// 测试---End
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.usernameTextField.text] isEqualToString:@""] ||
       [[Util trimString:self.passwordTextField.text] isEqualToString:@""] ||
       [[Util trimString:self.codeTextField.text] isEqualToString:@""]) {
        [self showAlert:@"信息填写不完整"];
        
        return NO;
    }
    
    if(![self.codeTextField.text isEqualToString:self.codeLabel.text]) {
        [self showAlert:@"验证码错误"];
        
        return NO;
    }
    
    return YES;
}

- (void)login
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        [self addLoadingView];
        
        NSString *postString = [NSString stringWithFormat:@"{loginName:'%@',loginPassWord:'%@'}", self.usernameTextField.text, self.passwordTextField.text];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:LOGIN_USER_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestLoginFinished:) didFailSelector:@selector(requestLoginFailed:)];
    }
}

- (void)requestLoginFinished:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        NSString *ajaxToken = [jsonDict stringForKey:@"ajax_token"];
        if([ajaxToken integerValue] == 0) {
            DadeAppDelegate.userInfo = [[UserInfo alloc] initWithDict:jsonDict];
            
            CaptchaViewController *viewController = [[CaptchaViewController alloc] initWithNibName:@"CaptchaViewController" bundle:nil];
            [self.navigationController pushViewController:viewController animated:YES];
        } else {
            NSString *ajaxMessage = [jsonDict stringForKey:@"ajax_message"];
            [self showAlert:ajaxMessage];
            
            self.codeLabel.text = [self randomCode];
        }
    }
    
    [self requestDidFinish:request];
}

- (void)requestLoginFailed:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    [self requestDidFail:request];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([self isRequesting]) {
        return NO;
    }
    
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
        [self.passwordTextField becomeFirstResponder];
    } else if(textField == self.passwordTextField) {
        [self.codeTextField becomeFirstResponder];
    } else if(textField == self.codeTextField) {
        [self.codeTextField resignFirstResponder];
        [self login];
    }
    
    return YES;
}

@end
