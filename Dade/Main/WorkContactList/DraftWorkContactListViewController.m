//
//  DraftWorkContactListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-30.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "DraftWorkContactListViewController.h"

#import "PersonnelListViewController.h"

@interface DraftWorkContactListViewController ()

- (void)initView;
- (BOOL)checkValidity;
- (void)send;
- (void)save;

@end

@implementation DraftWorkContactListViewController

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
        
        _entranceType = ENTRANCE_TYPE_DRAFT;
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
    
    if(ENTRANCE_TYPE_DRAFT == self.entranceType) {
        [self setNavigationBarTitle:@"工作联系单"];
    } else {
        [self setNavigationBarTitle:@"草稿详情"];
    }
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
    [self setRightBarButtonItem:@selector(saveClicked:) title:@"保存"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

- (void)saveClicked:(UIButton *)button
{
    // 保存
    
    [self save];
}

- (IBAction)addButtonClicked:(UIButton *)button
{
    // 添加
    
    PersonnelListViewController *viewController = [[PersonnelListViewController alloc] initWithNibName:@"PersonnelListViewController" bundle:nil];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)sendButtonClicked:(UIButton *)button
{
    // 发送
    
    [self send];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.dateTextField isFirstResponder]) {
        maxOffsetY = self.dateView.frame.origin.y;
        minOffsetY = self.dateView.frame.origin.y + self.dateView.frame.size.height + keyboardFrame.size.height - self.draftWorkContactListScrollView.frame.size.height;
    } else if([self.smsAlertTextField isFirstResponder]) {
        maxOffsetY = self.smsAlertView.frame.origin.y;
        minOffsetY = self.smsAlertView.frame.origin.y + self.smsAlertView.frame.size.height + keyboardFrame.size.height - self.draftWorkContactListScrollView.frame.size.height;
    } else if([self.subjectTextField isFirstResponder]) {
        maxOffsetY = self.subjectView.frame.origin.y;
        minOffsetY = self.subjectView.frame.origin.y + self.subjectView.frame.size.height + keyboardFrame.size.height - self.draftWorkContactListScrollView.frame.size.height;
    } else if([self.contentTextView isFirstResponder]) {
        maxOffsetY = self.contentView.frame.origin.y;
        minOffsetY = self.contentView.frame.origin.y + self.contentView.frame.size.height + keyboardFrame.size.height - self.draftWorkContactListScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.draftWorkContactListScrollView.contentOffset.y) {
        [self.draftWorkContactListScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.draftWorkContactListScrollView.contentOffset.y < minOffsetY) {
        [self.draftWorkContactListScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat scrollMaxOffsetY = self.draftWorkContactListScrollView.contentSize.height - self.draftWorkContactListScrollView.frame.size.height;
    if(self.draftWorkContactListScrollView.contentOffset.y > scrollMaxOffsetY) {
        [self.draftWorkContactListScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
    }
}

- (void)dismissKeyboard
{
    if([self.contentTextView isFirstResponder]) {
        [self.contentTextView resignFirstResponder];
    }
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
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    inputAccessoryView.items = buttonArray;
    self.contentTextView.inputAccessoryView = inputAccessoryView;
    
    // 测试---Start
    self.senderLabel.text = @"王冬王冬冬王冬冬王冬冬王冬冬王冬冬";
    self.recipientsLabel.text = @"大家大家大家大家大家大家大家大家大家大家大家大家大家大家大家大家大家大家大家大家大家";
    // 测试---End
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.dateTextField.text] isEqualToString:@""]) {
        [self showAlert:@"指定完成时间不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.smsAlertTextField.text] isEqualToString:@""]) {
        [self showAlert:@"短信提醒不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.subjectTextField.text] isEqualToString:@""]) {
        [self showAlert:@"题目不能为空"];

        return NO;
    }
    
    if([[Util trimString:self.contentTextView.text] isEqualToString:@""]) {
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

- (void)save
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
    if(textField == self.dateTextField) {
        [self.dateTextField resignFirstResponder];
        [self.smsAlertTextField becomeFirstResponder];
    } else if(textField == self.smsAlertTextField) {
        [self.smsAlertTextField resignFirstResponder];
        [self.subjectTextField becomeFirstResponder];
    } else if(textField == self.subjectTextField) {
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
