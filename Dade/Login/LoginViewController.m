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
- (void)requestLoginFinished:(NSString *)jsonString;
- (void)requestLoginFailed;

- (void)queryVersionNumber;
- (void)requestQueryVersionNumberFinished:(NSString *)jsonString;
- (void)requestQueryVersionNumberFailed;

- (void)showVersionAlert;
- (void)downloadApp;

@end

@implementation LoginViewController
{
    NSString *_latestVersionNumber;     // 最新的版本号
    NSString *_appDownloadUrl;          // 应用下载地址
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self queryVersionNumber];
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
    
    if(DEPLOYMENT_ENVIRONMENT == 1) {
        self.usernameTextField.text = @"gaoxs";
        self.passwordTextField.text = @"123456";
        self.codeTextField.text = @"9999";
        self.codeLabel.text = @"9999";
    }
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
        
        [self startLoading];
        
//        loginName：用户登录名
//        loginPassWord：用户登录密码
        
        NSString *postString = [NSString stringWithFormat:@"{loginName:'%@',loginPassWord:'%@'}", self.usernameTextField.text, self.passwordTextField.text];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:LOGIN_USER_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestLoginFinished:) didFailSelector:@selector(requestLoginFailed)];
    }
}

- (void)requestLoginFinished:(NSString *)jsonString
{
    [self stopLoading];

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
}

- (void)requestLoginFailed
{
    [self stopLoading];
}

- (void)queryVersionNumber
{
//    type：版本类型（app发送：“app”，ios发送：“ios”）
    
    NSString *postString = [NSString stringWithFormat:@"{type:'%@'}", @"ios"];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_VERSION_NUMBER_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryVersionNumberFinished:) didFailSelector:@selector(requestQueryVersionNumberFailed)];
}

- (void)requestQueryVersionNumberFinished:(NSString *)jsonString
{
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        if(DEPLOYMENT_ENVIRONMENT == 1) {
            _latestVersionNumber = @"2.0";
            _appDownloadUrl = @"http://www.baidu.com";
        } else {
            _latestVersionNumber = [jsonDict stringForKey:@"versionCode"];
            _appDownloadUrl = [jsonDict stringForKey:@"versionUrl"];
        }
        
        if(![_latestVersionNumber isEqualToString:@""] && ![_latestVersionNumber isEqualToString:DadeAppVersion]) {
            if(![_appDownloadUrl isEqualToString:@""]) {
                [self showVersionAlert];
            }
        }
    }
}

- (void)requestQueryVersionNumberFailed
{
}

- (void)showVersionAlert
{
    NSString *title = [NSString stringWithFormat:@"发现新版本%@，是否立即更新？", _latestVersionNumber];
    
    if(IOS_VERSION_8_OR_ABOVE) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"否"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action) {
                                                         }];
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle:@"是"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [self downloadApp];
                                                          }];
        [alertController addAction:noAction];
        [alertController addAction:yesAction];
        
        [self presentViewController:alertController animated:YES completion:NULL];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"否"
                                                  otherButtonTitles:@"是", nil];
        [alertView show];
    }
}

- (void)downloadApp
{
    NSURL *url = [NSURL URLWithString:_appDownloadUrl];
    if([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.cancelButtonIndex != buttonIndex) {
        [self downloadApp];
    }
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
