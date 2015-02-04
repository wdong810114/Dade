//
//  NotPunchExplainViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "NotPunchExplainViewController.h"

@interface NotPunchExplainViewController ()

- (void)initView;
- (BOOL)checkValidity;

- (void)saveNotPunch;
- (void)requestSaveNotPunchFinished:(ASIHTTPRequest *)request;
- (void)requestSaveNotPunchFailed:(ASIHTTPRequest *)request;

@end

@implementation NotPunchExplainViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"未打卡说明"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    if([self isRequesting]) {
        return;
    }
    
    [self pop];
}

- (IBAction)reportButtonClicked:(UIButton *)button
{
    // 呈报
    
    if([self isRequesting]) {
        return;
    }
    
    [self saveNotPunch];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.numberTextField isFirstResponder]) {
        maxOffsetY = self.numberView.frame.origin.y;
        minOffsetY = self.numberView.frame.origin.y + self.numberView.frame.size.height + keyboardFrame.size.height - self.notPunchExplainScrollView.frame.size.height;
    } else if([self.dateTextField isFirstResponder]) {
        maxOffsetY = self.dateView.frame.origin.y;
        minOffsetY = self.dateView.frame.origin.y + self.dateView.frame.size.height + keyboardFrame.size.height - self.notPunchExplainScrollView.frame.size.height;
    } else if([self.notPunchTextView isFirstResponder]) {
        maxOffsetY = self.notPunchView.frame.origin.y;
        minOffsetY = self.notPunchView.frame.origin.y + self.notPunchView.frame.size.height + keyboardFrame.size.height - self.notPunchExplainScrollView.frame.size.height;
    } else if([self.explainTextView isFirstResponder]) {
        maxOffsetY = self.explainView.frame.origin.y;
        minOffsetY = self.explainView.frame.origin.y + self.explainView.frame.size.height + keyboardFrame.size.height - self.notPunchExplainScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.notPunchExplainScrollView.contentOffset.y) {
        [self.notPunchExplainScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.notPunchExplainScrollView.contentOffset.y < minOffsetY) {
        [self.notPunchExplainScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat scrollMaxOffsetY = self.notPunchExplainScrollView.contentSize.height - self.notPunchExplainScrollView.frame.size.height;
    if(self.notPunchExplainScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            [self.notPunchExplainScrollView setContentOffset:CGPointZero animated:YES];
        } else {
            [self.notPunchExplainScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
        }
    }
}

- (void)dismissKeyboard
{
    if([self.notPunchTextView isFirstResponder]) {
        [self.notPunchTextView resignFirstResponder];
    } else if([self.explainTextView isFirstResponder]) {
        [self.explainTextView resignFirstResponder];
    }
}

#pragma mark - Private Methods
- (void)initView
{
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.nameLabel.preferredMaxLayoutWidth = self.nameLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
    }
    
    self.nameLabel.text = DadeAppDelegate.userInfo.staffName;
    self.departmentLabel.text = DadeAppDelegate.userInfo.department;
    
    [self.reportButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.reportButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.reportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIToolbar *inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, INPUT_ACCESSORY_VIEW_HEIGHT)];
    inputAccessoryView.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    inputAccessoryView.items = buttonArray;
    self.notPunchTextView.inputAccessoryView = inputAccessoryView;
    self.explainTextView.inputAccessoryView = inputAccessoryView;
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.numberTextField.text] isEqualToString:@""]) {
        [self showAlert:@"考勤号不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.dateTextField.text] isEqualToString:@""]) {
        [self showAlert:@"未打卡日期不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.notPunchTextView.text] isEqualToString:@""] ||
       [[Util trimString:self.explainTextView.text] isEqualToString:@""]) {
        [self showAlert:@"内容不能为空"];
        
        return NO;
    }
    
    return YES;
}

- (void)saveNotPunch
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        [self addLoadingView];
        
//        attendance：考勤号
//        cardDate：未打卡日期
//        content：未打卡说明
//        exaContent：审批说明
//        orgId：组织架构Id
//        depOrgId：部门组织架构ID
//        userId：用户Id
        
//        NSString *postString = [NSString stringWithFormat:@"{attendance:'%@',cardDate:'%@',content:'%@',exaContent:'%@',orgId:'%@',depOrgId:'%@',userId:'%@'}", self.dateTextField.text, self.notPunchTextView.text, self.explainTextView.text, DadeAppDelegate.userInfo.orgId, DadeAppDelegate.userInfo.depOrgId, DadeAppDelegate.userInfo.staffId];
//        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
//        
//        ASIFormDataRequest *request = [self requestWithRelativeURL:SAVE_NOT_PUNCH_REQUEST_URL];
//        [request setPostBody:postData];
//        [self startRequest:request didFinishSelector:@selector(requestSaveNotPunchFinished:) didFailSelector:@selector(requestSaveNotPunchFailed:)];
    }
}

- (void)requestSaveNotPunchFinished:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        NSString *ajaxToken = [jsonDict stringForKey:@"ajax_token"];
        if([ajaxToken integerValue] != 0) {
            NSString *ajaxMessage = [jsonDict stringForKey:@"ajax_message"];
            [self showAlert:ajaxMessage];
        }
    }
    
    [self requestDidFinish:request];
}

- (void)requestSaveNotPunchFailed:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    [self requestDidFail:request];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([self isRequesting]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.numberTextField) {
        [self.dateTextField becomeFirstResponder];
    } else if(textField == self.dateTextField) {
        [self.dateTextField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([self isRequesting]) {
        return NO;
    }

    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView == self.notPunchTextView) {
        if([Util isEmptyString:self.notPunchTextView.text]) {
            self.notPunchPlaceholderLabel.alpha = 1.0;
        } else {
            self.notPunchPlaceholderLabel.alpha = 0.0;
        }
    } else if(textView == self.explainTextView) {
        if([Util isEmptyString:self.explainTextView.text]) {
            self.explainPlaceholderLabel.alpha = 1.0;
        } else {
            self.explainPlaceholderLabel.alpha = 0.0;
        }
    }
}

@end
