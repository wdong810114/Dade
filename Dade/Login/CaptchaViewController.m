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

- (void)sendCaptcha;
- (void)requestSendCaptchaFinished:(ASIHTTPRequest *)request;
- (void)requestSendCaptchaFailed:(ASIHTTPRequest *)request;

@end

@implementation CaptchaViewController
{
    NSString *_captcha;
    NSInteger _tryTimes;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self sendCaptcha];
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
    
    if([self isRequesting]) {
        return;
    }
    
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
    if([[Util trimString:self.captchaTextField.text] isEqualToString:@""]) {
        [self showAlert:@"请输入验证码"];
        
        return NO;
    }
    
    if(![self.captchaTextField.text isEqualToString:_captcha]) {
        _tryTimes += 1;
        if(_tryTimes == 3) {
            [self sendCaptcha];
            
            _tryTimes = 0;
        } else {
            [self showAlert:[NSString stringWithFormat:@"验证码错误，%i次后重新获取验证码", 3 - _tryTimes]];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)login
{
    [self.view endEditing:YES];
    
    if([self checkValidity]) {
        [DadeAppDelegate loginSuccessed];
    }
}

- (void)sendCaptcha
{
    [self addLoadingView];
    
    NSString *postString = [NSString stringWithFormat:@"{userId:'%@'}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:SEND_TEXT_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestSendCaptchaFinished:) didFailSelector:@selector(requestSendCaptchaFailed:)];
}

- (void)requestSendCaptchaFinished:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        _captcha = [jsonDict stringForKey:@"random "];
// 测试---Start
        self.captchaTextField.text = _captcha;
// 测试---End
    }
    
    [self requestDidFinish:request];
}

- (void)requestSendCaptchaFailed:(ASIHTTPRequest *)request
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
