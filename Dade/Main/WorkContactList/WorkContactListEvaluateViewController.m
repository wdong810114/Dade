//
//  WorkContactListEvaluateViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-10.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "WorkContactListEvaluateViewController.h"

@interface WorkContactListEvaluateViewController ()

- (void)evaluateTodoWork;
- (void)requestEvaluateTodoWorkFinished:(NSString *)jsonString;
- (void)requestEvaluateTodoWorkFailed;

@end

@implementation WorkContactListEvaluateViewController

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
    
    [self setNavigationBarTitle:@"评价"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

- (IBAction)evaluateButtonClicked:(UIButton *)button
{
    // 评价
    
    if([self isRequesting]) {
        return;
    }
    
    [self evaluateTodoWork];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.scoreTextField isFirstResponder]) {
        maxOffsetY = self.scoreView.frame.origin.y;
        minOffsetY = self.scoreView.frame.origin.y + self.scoreView.frame.size.height + keyboardFrame.size.height - self.evaluateScrollView.frame.size.height;
    } else if([self.contentTextView isFirstResponder]) {
        maxOffsetY = self.contentView.frame.origin.y;
        minOffsetY = self.contentView.frame.origin.y + self.contentView.frame.size.height + keyboardFrame.size.height - self.evaluateScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.evaluateScrollView.contentOffset.y) {
        [self.evaluateScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.evaluateScrollView.contentOffset.y < minOffsetY) {
        [self.evaluateScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat scrollMaxOffsetY = self.evaluateScrollView.contentSize.height - self.evaluateScrollView.frame.size.height;
    if(self.evaluateScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            [self.evaluateScrollView setContentOffset:CGPointZero animated:YES];
        } else {
            [self.evaluateScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
        }
    }
}

- (void)dismissKeyboard
{
    [self.contentTextView resignFirstResponder];
}

#pragma mark - Private Methods
- (void)initView
{
    [self.evaluateButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.evaluateButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.evaluateButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIToolbar *inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, INPUT_ACCESSORY_VIEW_HEIGHT)];
    inputAccessoryView.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    inputAccessoryView.items = buttonArray;
    self.contentTextView.inputAccessoryView = inputAccessoryView;
    
    if(![[Util trimString:self.evaluateScore] isEqualToString:@""] && ![[Util trimString:self.evaluateContent] isEqualToString:@""]) {
        self.scoreTextField.text = self.evaluateScore;
        self.contentTextView.text = self.evaluateContent;
        self.placeholderLabel.alpha = 0.0;
        self.evaluateButton.alpha = 0.0;
    }
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.scoreTextField.text] isEqualToString:@""]) {
        [self showAlert:@"分数不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.contentTextView.text] isEqualToString:@""]) {
        [self showAlert:@"内容不能为空"];
        
        return NO;
    }
    
    if(![Util isValidScore:self.scoreTextField.text]) {
        [self showAlert:@"分数不合法"];
        
        return NO;
    }
    
    return YES;
}

- (void)evaluateTodoWork
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        [self startLoading];
        
//    workId：工作联系单Id
//    nsId：工作联系单人员关系表ID
//    score：评价分数
//    assess：评价内容
//    endMark：完结工作联系单标示（0：不完结 1：完结）
//    staffId：用户ID
        
        NSString *endMark = self.isLastEvaluate ? @"1" : @"0";
        
        NSString *postString = [NSString stringWithFormat:@"{\"workId\":\"%@\",\"nsId\":\"%@\",\"score\":\"%@\",\"assess\":\"%@\",\"endMark\":\"%@\",\"staffId\":\"%@\"}", self.workId, self.relationId, self.scoreTextField.text, self.contentTextView.text, endMark, DadeAppDelegate.userInfo.staffId];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:EVALUATION_TODO_WORK_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestEvaluateTodoWorkFinished:) didFailSelector:@selector(requestEvaluateTodoWorkFailed)];
    }
}

- (void)requestEvaluateTodoWorkFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        NSString *ajaxToken = [jsonDict stringForKey:@"ajax_token"];
        if([ajaxToken integerValue] != 0) {
            NSString *ajaxMessage = [jsonDict stringForKey:@"ajax_message"];
            [self showAlert:ajaxMessage];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:DDWorkContactListDetailRefreshNotification object:nil];
        }
    }
}

- (void)requestEvaluateTodoWorkFailed
{
    [self stopLoading];
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
    if(textField == self.scoreTextField) {
        [self.scoreTextField resignFirstResponder];
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
    if(textView == self.contentTextView) {
        if([Util isEmptyString:self.contentTextView.text]) {
            self.placeholderLabel.alpha = 1.0;
        } else {
            self.placeholderLabel.alpha = 0.0;
        }
    }
}

@end
