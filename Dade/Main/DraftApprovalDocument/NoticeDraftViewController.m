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
- (void)removePickerPanel;

- (void)draftNoticeInfo;
- (void)requestDraftNoticeInfoFinished:(NSString *)jsonString;
- (void)requestDraftNoticeInfoFailed;

@end

@implementation NoticeDraftViewController
{
    CGPoint _scrollViewContentOffset;   // 解决iOS6下bug
        
    NSArray *_recipientIdArray;
    BOOL _isFeedback;
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.noticeDraftScrollView.contentOffset = CGPointZero;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _scrollViewContentOffset = self.noticeDraftScrollView.contentOffset;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.noticeDraftScrollView.contentOffset = _scrollViewContentOffset;
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
    // 部门
    
    if([self isRequesting]) {
        return;
    }
    
    [self.view endEditing:YES];
    [self removePickerPanel];
    
    if(!_departmentPickerPanel) {
        _departmentPickerPanel = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 216.0 + 44.0)];
        _departmentPickerPanel.backgroundColor = [UIColor whiteColor];
        
        UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0, 0.0, _departmentPickerPanel.frame.size.width, 44.0)];
        toolbar.barStyle = UIBarStyleDefault;
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(doneDepartmentClicked)];
        NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
        toolbar.items = buttonArray;
        
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, _departmentPickerPanel.frame.size.width, 216.0)];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.showsSelectionIndicator = YES;
        _departmentPickerView = pickerView;
        
        [_departmentPickerPanel addSubview:toolbar];
        [_departmentPickerPanel addSubview:pickerView];
        [self.view addSubview:_departmentPickerPanel];
    }
    
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
        [self.noticeDraftScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)doneDepartmentClicked
{
    NSString *department = [_departments objectAtIndex:[_departmentPickerView selectedRowInComponent:0]];
    if(![department isEqualToString:self.departmentLabel.text]) {
        self.departmentLabel.text = department;
        
        // 部门选择改变时，将部门名和职位名也同时改变
        NSInteger orgIndex = [_departments indexOfObject:self.departmentLabel.text];
        OrganizationInfo *orgInfo = DadeAppDelegate.userInfo.organizationArray[orgIndex];
        self.departmentLabel.text = orgInfo.department;
    }
    
    [self removePickerPanel];
}

- (IBAction)addButtonClicked:(UIButton *)button
{
    // 添加
    
    if([self isRequesting]) {
        return;
    }
    
    [self.view endEditing:YES];
    [self removePickerPanel];
    
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
    // 完结回馈
    
    if([self isRequesting]) {
        return;
    }
    
    [self.view endEditing:YES];
    [self removePickerPanel];
    
    _isFeedback = !_isFeedback;
    self.checkImageView.image = _isFeedback ? [UIImage imageNamed:@"row_selected_icon"] : [UIImage imageNamed:@"row_unselected_icon"];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.subjectTextField isFirstResponder]) {
        maxOffsetY = self.subjectView.frame.origin.y;
        minOffsetY = self.subjectView.frame.origin.y + self.subjectView.frame.size.height + keyboardFrame.size.height - self.noticeDraftScrollView.frame.size.height;
    } else if([self.contentTextView isFirstResponder]) {
        maxOffsetY = self.contentView.frame.origin.y;
        minOffsetY = self.contentView.frame.origin.y + self.contentView.frame.size.height + keyboardFrame.size.height - self.noticeDraftScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.noticeDraftScrollView.contentOffset.y) {
        [self.noticeDraftScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.noticeDraftScrollView.contentOffset.y < minOffsetY) {
        [self.noticeDraftScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat scrollMaxOffsetY = self.noticeDraftScrollView.contentSize.height - self.noticeDraftScrollView.frame.size.height;
    if(self.noticeDraftScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            [self.noticeDraftScrollView setContentOffset:CGPointZero animated:YES];
        } else {
            [self.noticeDraftScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
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
        self.recipientsLabel.preferredMaxLayoutWidth = self.recipientsLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
    }

    OrganizationInfo *orgInfo = DadeAppDelegate.userInfo.organizationArray[0];
    self.departmentLabel.text = orgInfo.department;
    
    self.departmentLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(departmentClicked)];
    [self.departmentLabel addGestureRecognizer:tapGestureRecognizer1];
    self.feedbackLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(feedbackClicked)];
    [self.feedbackLabel addGestureRecognizer:tapGestureRecognizer2];
    
    self.departmentArrowImageView.image = [UIImage imageNamed:@"down_arrow"];
    self.checkImageView.image = [UIImage imageNamed:@"row_unselected_icon"];
    
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
    if([[Util trimString:self.recipientsLabel.text] isEqualToString:@""]) {
        [self showAlert:@"通知人员不能为空"];
        
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
        [self.view endEditing:YES];
        [self removePickerPanel];
        
        [self startLoading];
        
//        userId ：用户Id
//        fileTypeId: 文件类型Id
//        displayvalue：主题
//        filenum：编号
//        content：内容
//        staffIds：收件人(以“|”间隔)
//        temp：部门(由org_id|qyid|depOrgid组成，以“|”间隔)
//        isEnd：是否完结
        
        NSInteger orgIndex = [_departments indexOfObject:self.departmentLabel.text];
        OrganizationInfo *orgInfo = DadeAppDelegate.userInfo.organizationArray[orgIndex];
        
        NSString *staffIds = [_recipientIdArray componentsJoinedByString:@"|"];
        NSString *temp = [NSString stringWithFormat:@"%@|%@|%@", orgInfo.orgId, orgInfo.qyId, orgInfo.depOrgId];
        NSString *isEnd = _isFeedback ? @"1" : @"0";
        
        NSString *postString = [NSString stringWithFormat:@"{\"userId\":\"%@\",\"fileTypeId\":\"5\",\"displayvalue\":\"%@\",\"filenum\":\"\",\"content\":\"%@\",\"staffIds\":\"%@\",\"temp\":\"%@\",\"isEnd\":\"%@\"}", DadeAppDelegate.userInfo.staffId, self.subjectTextField.text, self.contentTextView.text, staffIds, temp, isEnd];
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
    [self.view endEditing:YES];
    [self removePickerPanel];
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
    return [_departments count];
}

#pragma mark - UIPickerViewDelegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_departments objectAtIndex:row];
}

#pragma mark - PersonnelListViewControllerDelegate Methods
- (void)personnelListViewController:(PersonnelListViewController *)personnelListViewController didSelectIds:(NSArray *)idArray didSelectNames:(NSArray *)nameArray
{
    _recipientIdArray = [NSArray arrayWithArray:idArray];
    self.recipientsLabel.text = [nameArray componentsJoinedByString:@"|"];
}

@end
