//
//  DraftWorkContactListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-30.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "DraftWorkContactListViewController.h"

@interface DraftWorkContactListViewController ()

- (void)initView;
- (BOOL)checkValidity;

- (void)queryTodoWorkInfo;
- (void)requestQueryTodoWorkInfoFinished:(NSString *)jsonString;
- (void)requestQueryTodoWorkInfoFailed;
- (void)saveOrUpdateTodoWord:(NSInteger)type;
- (void)requestSaveOrUpdateTodoWordFinished:(NSString *)jsonString;
- (void)requestSaveOrUpdateTodoWordFailed;

@end

@implementation DraftWorkContactListViewController
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
    
    if(self.workId) {
        [self queryTodoWorkInfo];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.draftWorkContactListScrollView.contentOffset = CGPointZero;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _scrollViewContentOffset = self.draftWorkContactListScrollView.contentOffset;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.draftWorkContactListScrollView.contentOffset = _scrollViewContentOffset;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    if(self.workId) {
        [self setNavigationBarTitle:@"草稿详情"];
    } else {
        [self setNavigationBarTitle:@"工作联系单"];
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
    
    if([self isRequesting]) {
        return;
    }
    
    [self saveOrUpdateTodoWord:0];
}

- (IBAction)sendButtonClicked:(UIButton *)button
{
    // 发送
    
    if([self isRequesting]) {
        return;
    }
    
    [self saveOrUpdateTodoWord:1];
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
    
    self.senderLabel.text = DadeAppDelegate.userInfo.staffName;
    
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
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.senderLabel.text] isEqualToString:@""]) {
        [self showAlert:@"收件人不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.dateTextField.text] isEqualToString:@""]) {
        [self showAlert:@"指定完成时间不能为空"];
        
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
    
    if(![Util isValidDate:self.dateTextField.text]) {
        [self showAlert:@"指定完成时间不合法"];
        
        return NO;
    }
    
    return YES;
}

- (void)queryTodoWorkInfo
{
    [self startLoading];
    
//    workId：工作联系单Id
    
    NSString *postString = [NSString stringWithFormat:@"{workId:'%@'}", self.workId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_TODO_WORK_INFO_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryTodoWorkInfoFinished:) didFailSelector:@selector(requestQueryTodoWorkInfoFailed)];
}

- (void)requestQueryTodoWorkInfoFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        self.senderLabel.text = [jsonDict stringForKey:@"staffName"];
        self.dateTextField.text = [jsonDict stringForKey:@"appointTime"];
        self.smsAlertTextField.text = [jsonDict stringForKey:@"datePh"];
        self.subjectTextField.text = [jsonDict stringForKey:@"displayvalue"];
        
        NSString *content = [jsonDict stringForKey:@"content"];
        if(content.length > 0) {
            self.contentTextView.text = content;
            self.placeholderLabel.alpha = 0.0;
        }
        
        NSMutableString *recipients = [NSMutableString stringWithString:[jsonDict stringForKey:@"addressees"]];
        if(recipients.length > 0) {
            [recipients deleteCharactersInRange:NSMakeRange(recipients.length - 1, 1)];
            [recipients replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:NSMakeRange(0, recipients.length)];
            [recipients replaceOccurrencesOfString:@";" withString:@"|" options:NSLiteralSearch range:NSMakeRange(0, recipients.length)];
            self.recipientsLabel.text = recipients;
        }
        
        NSMutableString *recipientsIds = [NSMutableString stringWithString:[jsonDict stringForKey:@"addresseesIds"]];
        if(recipientsIds.length > 0) {
            [recipientsIds deleteCharactersInRange:NSMakeRange(recipientsIds.length - 1, 1)];
            _recipientIdArray = [[NSMutableArray alloc] initWithArray:[recipientsIds componentsSeparatedByString:@","]];
        }
    }
}

- (void)requestQueryTodoWorkInfoFailed
{
    [self stopLoading];
}

- (void)saveOrUpdateTodoWord:(NSInteger)type    // 0：草稿 1：发送
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        [self startLoading];
        
//        doType：状态 草稿0，已发1
//        staffIds：收件人ID，（多个ID用','号分割）
//        phone：是否短信提醒，0不提醒，1提醒
//        date_ph：短信提醒天数
//        appoint_time：指定完成时间yyyy-MM-dd
//        displayvalue：主题
//        content：内容
//        wordId：工作联系单ID（更新，保存时使用）
//        staffId：发件人ID
        
        NSString *doType = [NSString stringWithFormat:@"%i", (int)type];
        NSString *staffIds = [_recipientIdArray componentsJoinedByString:@","];
        NSString *isSMSAlert = [Util isEmptyString:self.smsAlertTextField.text] ? @"0" : @"1";
        
        NSString *postString = [NSString stringWithFormat:@"{doType:'%@',staffIds:'%@',phone:'%@',date_ph:'%@',appoint_time:'%@',displayvalue:'%@',content:'%@',wordId:'',staffId:'%@'}", doType, staffIds, isSMSAlert, self.smsAlertTextField.text, self.dateTextField.text, self.subjectTextField.text, self.contentTextView.text, DadeAppDelegate.userInfo.staffId];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:SAVE_OR_UPDATE_TODO_WORD_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestSaveOrUpdateTodoWordFinished:) didFailSelector:@selector(requestSaveOrUpdateTodoWordFailed)];
    }
}

- (void)requestSaveOrUpdateTodoWordFinished:(NSString *)jsonString
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
            [[NSNotificationCenter defaultCenter] postNotificationName:DDWorkContactListNumberRefreshNotification object:nil];
            [self performSelector:@selector(pop)];
        }
    }
}

- (void)requestSaveOrUpdateTodoWordFailed
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
