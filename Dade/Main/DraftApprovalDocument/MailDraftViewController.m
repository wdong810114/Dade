//
//  MailDraftViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "MailDraftViewController.h"

@interface MailDraftViewController ()

- (void)initView;
- (BOOL)checkValidity;
- (void)send;

@end

@implementation MailDraftViewController

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
    
    [self setNavigationBarTitle:@"邮件起草"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

- (IBAction)addButtonClicked:(UIButton *)button
{
    // 添加
    
}

- (IBAction)sendButtonClicked:(UIButton *)button
{
    // 发送
    
    [self send];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    
    if([self.subjectTextField isFirstResponder]) {
        CGFloat offsetY = self.subjectView.frame.origin.y + self.subjectView.frame.size.height + keyboardFrame.size.height - self.mailDraftScrollView.frame.size.height;
        if(offsetY > 0.0) {
            [self.mailDraftScrollView setContentOffset:CGPointMake(0.0, self.subjectView.frame.origin.y - 15.0)];
        }
    } else if([self.contentTextView isFirstResponder]) {
        CGFloat offsetY = self.contentView.frame.origin.y + self.contentView.frame.size.height + keyboardFrame.size.height - self.mailDraftScrollView.frame.size.height;
        if(offsetY > 0.0) {
            [self.mailDraftScrollView setContentOffset:CGPointMake(0.0, self.contentView.frame.origin.y - 15.0)];
        }
    }

    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    UIViewAnimationCurve curve = [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:duration];
    [UIView setAnimationCurve:curve];
    
    [self.mailDraftScrollView setContentOffset:CGPointZero];
    
    [UIView commitAnimations];
}

- (void)dismissKeyboard
{
    [self.contentTextView resignFirstResponder];
}

#pragma mark - Private Methods
- (void)initView
{
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.senderLabel.preferredMaxLayoutWidth = self.senderLabel.bounds.size.width;
        self.recipientsLabel.preferredMaxLayoutWidth = self.recipientsLabel.bounds.size.width;
    }
    
    [self.addButton setTitleColor:BLUE_BUTTON_TITLE_NORMAL_COLOR forState:UIControlStateNormal];
    [self.addButton setTitleColor:BLUE_BUTTON_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    
    [self.sendButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIToolbar *inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, INPUT_ACCESSORY_VIEW_HEIGHT)];
    inputAccessoryView.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    inputAccessoryView.items = buttonArray;
    self.contentTextView.inputAccessoryView = inputAccessoryView;
    
// 测试---Start
    self.senderLabel.text = @"王冬王冬冬王冬冬王冬冬王冬冬王冬冬王冬冬王冬冬王冬冬";
    self.recipientsLabel.text = @"葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;";
    self.subjectTextField.text = @"日程表";
// 测试---End
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.recipientsLabel.text] isEqualToString:@""]) {
        [self showAlert:@"收件人不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.subjectTextField.text] isEqualToString:@""] ||
       [[Util trimString:self.contentTextView.text] isEqualToString:@""]) {
        [self showAlert:@"内容不能为空"];
        
        return NO;
    }
    
    return YES;
}

- (void)send
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
    }
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.subjectTextField) {
        [self.subjectTextField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
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
