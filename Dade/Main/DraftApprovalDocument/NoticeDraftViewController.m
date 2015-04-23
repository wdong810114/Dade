//
//  NoticeDraftViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "NoticeDraftViewController.h"

@interface NoticeDraftViewController ()

- (void)initView;
- (BOOL)checkValidity;
- (void)initPickerPanel;
- (void)removePickerPanel;

- (void)draftNoticeInfo;
- (void)requestDraftNoticeInfoFinished:(NSString *)jsonString;
- (void)requestDraftNoticeInfoFailed;

@end

@implementation NoticeDraftViewController
{
    CGPoint _scrollViewContentOffset;   // 解决iOS6下bug
    
    NSArray *_reportsIdArray;
    NSArray *_recipientIdArray;
    BOOL _isFeedback;
    BOOL _isSMSAlert;
    NSInteger _addType;     // 1：添加经办人 2：添加收件人
    
    UIView *_departmentPickerPanel;
    UIPickerView *_departmentPickerView;
    NSArray *_departments;  // 部门
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
        
        _departments = [DadeAppDelegate.userInfo allDepartments];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    [self initPickerPanel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.noticeDraftScrollView.contentOffset = CGPointZero;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        _scrollViewContentOffset = self.noticeDraftScrollView.contentOffset;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.noticeDraftScrollView.contentOffset = _scrollViewContentOffset;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"通知起草"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

- (void)departmentClicked
{
    // 部门-->发文
    
    if([self isRequesting]) {
        return;
    }
    
    [self.view endEditing:YES];
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect frame = _departmentPickerPanel.frame;
                         frame.origin.y = self.view.frame.size.height - frame.size.height;
                         _departmentPickerPanel.frame = frame;
                     } completion:^(BOOL finished) {
                     }];
    
    CGFloat maxOffsetY = self.departmentView.frame.origin.y;
    CGFloat minOffsetY = self.departmentView.frame.origin.y + self.departmentView.frame.size.height + _departmentPickerPanel.frame.size.height - self.noticeDraftScrollView.frame.size.height;

    if(maxOffsetY < self.noticeDraftScrollView.contentOffset.y) {
        [self.noticeDraftScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.noticeDraftScrollView.contentOffset.y < minOffsetY) {
        CGFloat scrollMaxOffsetY = self.noticeDraftScrollView.contentSize.height - self.noticeDraftScrollView.frame.size.height;
        
        self.noticeDraftScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, minOffsetY - scrollMaxOffsetY, 0.0);
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.noticeDraftScrollView.contentOffset = CGPointMake(0.0, minOffsetY);
                         }
         ];
    }
}

- (void)doneDepartmentClicked
{
    NSString *department = [_departments objectAtIndex:[_departmentPickerView selectedRowInComponent:0]];
    if(![department isEqualToString:self.departmentLabel.text]) {
        self.departmentLabel.text = department;
        
        // 发文选择改变时，将经办和发文也同时改变
        NSInteger orgIndex = [_departments indexOfObject:self.departmentLabel.text];
        OrganizationInfo *orgInfo = DadeAppDelegate.userInfo.organizationArray[orgIndex];
        self.handleLabel.text = orgInfo.department;
        self.departmentLabel.text = orgInfo.department;
    }
    
    [self removePickerPanel];
    
    self.noticeDraftScrollView.contentInset = UIEdgeInsetsZero;
    
    CGFloat scrollMaxOffsetY = self.noticeDraftScrollView.contentSize.height - self.noticeDraftScrollView.frame.size.height;
    if(self.noticeDraftScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            self.noticeDraftScrollView.contentOffset = CGPointZero;
        } else {
            self.noticeDraftScrollView.contentOffset = CGPointMake(0.0, scrollMaxOffsetY);
        }
    }
}

- (IBAction)reportsAddButtonClicked:(UIButton *)button
{
    // 添加经办人
    
    if([self isRequesting]) {
        return;
    }
    
    self.noticeDraftScrollView.contentInset = UIEdgeInsetsZero;
    
    [self.view endEditing:YES];
    [self removePickerPanel];
    
    _addType = 1;
    
    PersonnelListViewController *viewController = [[PersonnelListViewController alloc] initWithNibName:@"PersonnelListViewController" bundle:nil];
    viewController.delegate = self;
    viewController.selectedIdArray = [NSMutableArray arrayWithArray:_reportsIdArray];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)recipientsAddButtonClicked:(UIButton *)button
{
    // 添加收件人
    
    if([self isRequesting]) {
        return;
    }
    
    self.noticeDraftScrollView.contentInset = UIEdgeInsetsZero;
    
    [self.view endEditing:YES];
    [self removePickerPanel];
    
    _addType = 2;
    
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
    
    [self draftNoticeInfo];
}

- (void)feedbackClicked
{
    // 是否查收确认
    
    if([self isRequesting]) {
        return;
    }
    
    _isFeedback = !_isFeedback;
    self.feedbackCheckImageView.image = _isFeedback ? [UIImage imageNamed:@"row_selected_icon"] : [UIImage imageNamed:@"row_unselected_icon"];
}

- (void)smsAlertClicked
{
    // 短信提醒
    
    if([self isRequesting]) {
        return;
    }
    
    _isSMSAlert = !_isSMSAlert;
    self.smsAlertCheckImageView.image = _isSMSAlert ? [UIImage imageNamed:@"row_selected_icon"] : [UIImage imageNamed:@"row_unselected_icon"];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.markYearTextField isFirstResponder] || [self.markNumberTextField isFirstResponder]) {
        maxOffsetY = self.markView.frame.origin.y;
        minOffsetY = self.markView.frame.origin.y + self.markView.frame.size.height + keyboardFrame.size.height - self.noticeDraftScrollView.frame.size.height;
    } else if([self.contentTextView isFirstResponder]) {
        maxOffsetY = self.contentView.frame.origin.y;
        minOffsetY = self.contentView.frame.origin.y + self.contentView.frame.size.height + keyboardFrame.size.height - self.noticeDraftScrollView.frame.size.height;
    } else if([self.subjectTextField isFirstResponder]) {
        maxOffsetY = self.subjectView.frame.origin.y;
        minOffsetY = self.subjectView.frame.origin.y + self.subjectView.frame.size.height + keyboardFrame.size.height - self.noticeDraftScrollView.frame.size.height;
    } else if([self.subjectWordsTextField isFirstResponder]) {
        maxOffsetY = self.subjectWordsView.frame.origin.y;
        minOffsetY = self.subjectWordsView.frame.origin.y + self.subjectWordsView.frame.size.height + keyboardFrame.size.height - self.noticeDraftScrollView.frame.size.height;
    } else if([self.yearTextField isFirstResponder] || [self.monthTextField isFirstResponder] || [self.dayTextField isFirstResponder] || [self.copiesTextField isFirstResponder]) {
        maxOffsetY = self.dateView.frame.origin.y;
        minOffsetY = self.dateView.frame.origin.y + self.dateView.frame.size.height + keyboardFrame.size.height - self.noticeDraftScrollView.frame.size.height;
    } else if([self.smsAlertDaysTextField isFirstResponder]) {
        maxOffsetY = self.smsAlertView.frame.origin.y;
        minOffsetY = self.smsAlertView.frame.origin.y + self.smsAlertView.frame.size.height + keyboardFrame.size.height - self.noticeDraftScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.noticeDraftScrollView.contentOffset.y) {
        [self.noticeDraftScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.noticeDraftScrollView.contentOffset.y < minOffsetY) {
        CGFloat scrollMaxOffsetY = self.noticeDraftScrollView.contentSize.height - self.noticeDraftScrollView.frame.size.height;
        
        self.noticeDraftScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, minOffsetY - scrollMaxOffsetY, 0.0);
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.noticeDraftScrollView.contentOffset = CGPointMake(0.0, minOffsetY);
                         }
         ];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.noticeDraftScrollView.contentInset = UIEdgeInsetsZero;
    
    CGFloat scrollMaxOffsetY = self.noticeDraftScrollView.contentSize.height - self.noticeDraftScrollView.frame.size.height;
    if(self.noticeDraftScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            self.noticeDraftScrollView.contentOffset = CGPointZero;
        } else {
            self.noticeDraftScrollView.contentOffset = CGPointMake(0.0, scrollMaxOffsetY);
        }
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
        self.reportsLabel.preferredMaxLayoutWidth = self.reportsLabel.bounds.size.width;
        self.handleLabel.preferredMaxLayoutWidth = self.handleLabel.bounds.size.width;
        self.handlerLabel.preferredMaxLayoutWidth = self.handlerLabel.bounds.size.width;
        self.recipientsLabel.preferredMaxLayoutWidth = self.recipientsLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
    }
    
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSYearCalendarUnit fromDate:[NSDate date]];
    self.markYearTextField.text = [NSString stringWithFormat:@"%i", (int)dateComponents.year];

    OrganizationInfo *orgInfo = DadeAppDelegate.userInfo.organizationArray[0];
    self.handleLabel.text = orgInfo.department;
    self.handlerLabel.text = DadeAppDelegate.userInfo.staffName;
    self.departmentLabel.text = orgInfo.department;
    
    self.departmentLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(departmentClicked)];
    [self.departmentLabel addGestureRecognizer:tapGestureRecognizer1];
    self.feedbackLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(feedbackClicked)];
    [self.feedbackLabel addGestureRecognizer:tapGestureRecognizer2];
    self.smsAlertCheckView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smsAlertClicked)];
    [self.smsAlertCheckView addGestureRecognizer:tapGestureRecognizer3];
    
    self.departmentArrowImageView.image = [UIImage imageNamed:@"down_arrow"];
    self.feedbackCheckImageView.image = [UIImage imageNamed:@"row_unselected_icon"];
    self.smsAlertCheckImageView.image = [UIImage imageNamed:@"row_unselected_icon"];
    
    [self.reportsAddButton setTitleColor:BLUE_BUTTON_TITLE_NORMAL_COLOR forState:UIControlStateNormal];
    [self.reportsAddButton setTitleColor:BLUE_BUTTON_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    [self.recipientsAddButton setTitleColor:BLUE_BUTTON_TITLE_NORMAL_COLOR forState:UIControlStateNormal];
    [self.recipientsAddButton setTitleColor:BLUE_BUTTON_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    
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
    
    if(DEPLOYMENT_ENVIRONMENT == 2) {
        self.subjectTextField.text = @"测试通知";
        self.contentTextView.text = @"这是一个测试通知";
        self.yearTextField.text = @"2015";
        self.monthTextField.text = @"05";
        self.dayTextField.text = @"10";
        self.copiesTextField.text = @"15";
        self.smsAlertDaysTextField.text = @"2";
        self.subjectWordsTextField.text = @"测试关键词";
        self.markYearTextField.text = @"2015";
        self.markNumberTextField.text = @"001";
        
        self.contentPlaceholderLabel.alpha = 0.0;
    }
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.markYearTextField.text] isEqualToString:@""]) {
        [self showAlert:@"年号不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.markNumberTextField.text] isEqualToString:@""]) {
        [self showAlert:@"编号不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.contentTextView.text] isEqualToString:@""]) {
        [self showAlert:@"内容不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.subjectTextField.text] isEqualToString:@""]) {
        [self showAlert:@"主题不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.subjectWordsTextField.text] isEqualToString:@""]) {
        [self showAlert:@"主题词不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.reportsLabel.text] isEqualToString:@""]) {
        [self showAlert:@"抄报不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.yearTextField.text] isEqualToString:@""] ||
       [[Util trimString:self.monthTextField.text] isEqualToString:@""] ||
       [[Util trimString:self.dayTextField.text] isEqualToString:@""]) {
        [self showAlert:@"印发日期不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.copiesTextField.text] isEqualToString:@""]) {
        [self showAlert:@"印发份数不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.recipientsLabel.text] isEqualToString:@""]) {
        [self showAlert:@"收件人不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.smsAlertDaysTextField.text] isEqualToString:@""]) {
        [self showAlert:@"短信提醒天数不能为空"];
        
        return NO;
    }
    
    NSString *printDate = [NSString stringWithFormat:@"%@-%@-%@", self.yearTextField.text, self.monthTextField.text, self.dayTextField.text];
    if(![Util isValidDate:printDate]) {
        [self showAlert:@"印发日期不合法"];
        
        return NO;
    }
    
    if(![Util isValidNumber:self.copiesTextField.text]) {
        [self showAlert:@"印发份数不合法"];
        
        return NO;
    }
    
    if(![Util isValidNumber:self.smsAlertDaysTextField.text]) {
        [self showAlert:@"短信提醒天数不合法"];
        
        return NO;
    }
    
    return YES;
}

- (void)initPickerPanel
{
    if(!_departmentPickerPanel || !_departmentPickerView) {
        UIView *pickerPanel = [[UIView alloc] initWithFrame:CGRectMake(0.0, DEVICE_HEIGHT, DEVICE_WIDTH, PICKER_VIEW_HEIGHT + TOOLBAR_HEIGHT)];
        pickerPanel.backgroundColor = [UIColor whiteColor];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, pickerPanel.frame.size.width, TOOLBAR_HEIGHT)];
        toolbar.barStyle = UIBarStyleDefault;
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(doneDepartmentClicked)];
        NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
        toolbar.items = buttonArray;
        
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, TOOLBAR_HEIGHT, pickerPanel.frame.size.width, PICKER_VIEW_HEIGHT)];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.showsSelectionIndicator = YES;
        
        [pickerPanel addSubview:toolbar];
        [pickerPanel addSubview:pickerView];
        [self.view addSubview:pickerPanel];
        
        _departmentPickerView = pickerView;
        _departmentPickerPanel = pickerPanel;
    }
}

- (void)removePickerPanel
{
    if(_departmentPickerPanel) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             CGRect frame = _departmentPickerPanel.frame;
                             frame.origin.y = self.view.frame.size.height;
                             _departmentPickerPanel.frame = frame;
                         }
                         completion:NULL
         ];
    }
}

- (void)draftNoticeInfo
{
    if([self checkValidity]) {
        [self startLoading];
        
//        userId ：用户Id
//        fileTypeId: 文件类型Id
//        displayvalue：主题
//        filenum：编号
//        content：内容
//        staffIds：收件人(以“|”间隔)
//        temp：部门(由org_id|qyid|depOrgid组成，以“|”间隔)
//        isEnd：是否完结
//        phone：是否短信提醒1 提醒，0 不提醒
//        date_ph：提醒天数
//        char2：主题词
//        char3：经办
//        char4：标号 年
//        char5：编号
//        char6：份数
//        char7：年
//        char8：月
//        char9：日
//        text1：抄报Id
//        text2：抄报名称

        NSInteger orgIndex = [_departments indexOfObject:self.departmentLabel.text];
        OrganizationInfo *orgInfo = DadeAppDelegate.userInfo.organizationArray[orgIndex];
        
        NSString *userId = DadeAppDelegate.userInfo.staffId;
        NSString *fileTypeId = @"5";
        NSString *displayvalue = self.subjectTextField.text;
        NSString *filenum = @"";
        NSString *content = self.contentTextView.text;
        NSString *staffIds = [_recipientIdArray componentsJoinedByString:@"|"];
        NSString *temp = [NSString stringWithFormat:@"%@|%@|%@", orgInfo.orgId, orgInfo.qyId, orgInfo.depOrgId];
        NSString *isEnd = _isFeedback ? @"1" : @"0";
        NSString *phone = _isSMSAlert ? @"1" : @"0";
        NSString *date_ph = self.smsAlertDaysTextField.text;
        NSString *char2 = self.subjectWordsTextField.text;
        NSString *char3 = self.handleLabel.text;
        NSString *char4 = self.markYearTextField.text;
        NSString *char5 = self.markNumberTextField.text;
        NSString *char6 = self.copiesTextField.text;
        NSString *char7 = self.yearTextField.text;
        NSString *char8 = self.monthTextField.text;
        NSString *char9 = self.dayTextField.text;
        NSString *text1 = [_reportsIdArray componentsJoinedByString:@"|"];
        NSString *text2 = self.reportsLabel.text;
        
        NSString *postString = [NSString stringWithFormat:@"{\"userId\":\"%@\",\"fileTypeId\":\"%@\",\"displayvalue\":\"%@\",\"filenum\":\"%@\",\"content\":\"%@\",\"staffIds\":\"%@\",\"temp\":\"%@\",\"isEnd\":\"%@\",\"phone\":\"%@\",\"date_ph\":\"%@\",\"char2\":\"%@\",\"char3\":\"%@\",\"char4\":\"%@\",\"char5\":\"%@\",\"char6\":\"%@\",\"char7\":\"%@\",\"char8\":\"%@\",\"char9\":\"%@\",\"text1\":\"%@\",\"text2\":\"%@\"}", userId, fileTypeId, displayvalue, filenum, content, staffIds, temp, isEnd, phone, date_ph, char2, char3, char4, char5, char6, char7, char8, char9, text1, text2];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:DRAFT_NOTICE_INFO_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestDraftNoticeInfoFinished:) didFailSelector:@selector(requestDraftNoticeInfoFailed)];
    }
}

- (void)requestDraftNoticeInfoFinished:(NSString *)jsonString
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

- (void)requestDraftNoticeInfoFailed
{
    [self stopLoading];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView == self.noticeDraftScrollView) {
        self.noticeDraftScrollView.contentInset = UIEdgeInsetsZero;
        
        [self.view endEditing:YES];
        [self removePickerPanel];
    }
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([self isRequesting]) {
        return NO;
    }
    
    [self removePickerPanel];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.markYearTextField) {
        [self.markNumberTextField becomeFirstResponder];
    } else {
        [self.view endEditing:YES];
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([self isRequesting]) {
        return NO;
    }
    
    [self removePickerPanel];
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView == self.contentTextView) {
        if([Util isEmptyString:self.contentTextView.text]) {
            self.contentPlaceholderLabel.alpha = 1.0;
        } else {
            self.contentPlaceholderLabel.alpha = 0.0;
        }
    }
}

#pragma mark - UIPickerViewDataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return _departments.count;
}

#pragma mark - UIPickerViewDelegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_departments objectAtIndex:row];
}

#pragma mark - PersonnelListViewControllerDelegate Methods
- (void)personnelListViewController:(PersonnelListViewController *)personnelListViewController didSelectIds:(NSArray *)idArray didSelectNames:(NSArray *)nameArray
{
    if(_addType == 1) {
        _reportsIdArray = [NSArray arrayWithArray:idArray];
        self.reportsLabel.text = [nameArray componentsJoinedByString:@"|"];
    } else if(_addType == 2) {
        _recipientIdArray = [NSArray arrayWithArray:idArray];
        self.recipientsLabel.text = [nameArray componentsJoinedByString:@"|"];
    }
}

@end
