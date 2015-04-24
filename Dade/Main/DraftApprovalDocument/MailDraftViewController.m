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

- (void)saveMail;
- (void)requestSaveMailFinished:(NSString *)jsonString;
- (void)requestSaveMailFailed;

@end

@implementation MailDraftViewController
{
    CGPoint _scrollViewContentOffset;   // 解决iOS6下bug
    
    NSArray *_recipientIdArray;
}

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.mailDraftScrollView.contentOffset = CGPointZero;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        _scrollViewContentOffset = self.mailDraftScrollView.contentOffset;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.mailDraftScrollView.contentOffset = _scrollViewContentOffset;
    }
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
    
    if([self isRequesting]) {
        return;
    }
    
    PersonnelListViewController *viewController = [[PersonnelListViewController alloc] initWithNibName:@"PersonnelListViewController" bundle:nil];
    viewController.delegate = self;
    viewController.selectedIdArray = [NSMutableArray arrayWithArray:_recipientIdArray];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)sendButtonClicked:(UIButton *)button
{
    // 发送
    
    if([self isRequesting]) {
        return;
    }
    
    [self saveMail];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.subjectTextField isFirstResponder]) {
        maxOffsetY = self.subjectView.frame.origin.y;
        minOffsetY = self.subjectView.frame.origin.y + self.subjectView.frame.size.height + keyboardFrame.size.height - self.mailDraftScrollView.frame.size.height;
    } else if([self.contentTextView isFirstResponder]) {
        maxOffsetY = self.contentView.frame.origin.y;
        minOffsetY = self.contentView.frame.origin.y + self.contentView.frame.size.height + keyboardFrame.size.height - self.mailDraftScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.mailDraftScrollView.contentOffset.y) {
        [self.mailDraftScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.mailDraftScrollView.contentOffset.y < minOffsetY) {
        [self.mailDraftScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat scrollMaxOffsetY = self.mailDraftScrollView.contentSize.height - self.mailDraftScrollView.frame.size.height;
    if(self.mailDraftScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            [self.mailDraftScrollView setContentOffset:CGPointZero animated:YES];
        } else {
            [self.mailDraftScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
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
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.senderLabel.preferredMaxLayoutWidth = self.senderLabel.bounds.size.width;
        self.recipientsLabel.preferredMaxLayoutWidth = self.recipientsLabel.bounds.size.width;
    }
    
    self.senderLabel.text = DadeAppDelegate.userInfo.staffName;
    
    [self.addButton setTitleColor:BLUE_BUTTON_TITLE_NORMAL_COLOR forState:UIControlStateNormal];
    [self.addButton setTitleColor:BLUE_BUTTON_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    
    [self.sendButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIToolbar *inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, INPUT_ACCESSORY_VIEW_HEIGHT)];
    inputAccessoryView.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    inputAccessoryView.items = buttonArray;
    self.contentTextView.inputAccessoryView = inputAccessoryView;
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.recipientsLabel.text] isEqualToString:@""]) {
        [self showAlert:@"收件人不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.subjectTextField.text] isEqualToString:@""]) {
        [self showAlert:@"主题不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.contentTextView.text] isEqualToString:@""]) {
        [self showAlert:@"内容不能为空"];
        
        return NO;
    }
    
    return YES;
}

- (void)saveMail
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        [self startLoading];
        
//        staffIds：收件人ID（多人用“|”分割）
//        displayvalue 邮件主题
//        content 邮件内容
//        userId ：用户Id
        
        NSString *staffIds = _recipientIdArray.count == 0 ? @"" : [_recipientIdArray componentsJoinedByString:@"|"];
        
        NSString *postString = [NSString stringWithFormat:@"{\"staffIds\":\"%@\",\"displayvalue\":\"%@\",\"content\":\"%@\",\"userId\":\"%@\"}", staffIds, self.subjectTextField.text, self.contentTextView.text, DadeAppDelegate.userInfo.staffId];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:SAVE_MAIL_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestSaveMailFinished:) didFailSelector:@selector(requestSaveMailFailed)];
    }
}

- (void)requestSaveMailFinished:(NSString *)jsonString
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
            [self performSelector:@selector(pop)];
        }
    }
}

- (void)requestSaveMailFailed
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
    if(textField == self.subjectTextField) {
        [self.subjectTextField resignFirstResponder];
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

#pragma mark - PersonnelListViewControllerDelegate Methods
- (void)personnelListViewController:(PersonnelListViewController *)personnelListViewController didSelectIds:(NSArray *)idArray didSelectNames:(NSArray *)nameArray
{
    _recipientIdArray = [NSArray arrayWithArray:idArray];
    self.recipientsLabel.text = [nameArray componentsJoinedByString:@"|"];
}

@end
