//
//  LeaveApplyViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "LeaveApplyViewController.h"

@interface LeaveApplyViewController ()

- (void)initView;
- (BOOL)checkValidity;
- (void)updateApprovalView;
- (void)initPickerPanel;
- (void)removePickerPanel;

- (void)saveLeaveApplication;
- (void)requestSaveLeaveApplicationFinished:(NSString *)jsonString;
- (void)requestSaveLeaveApplicationFailed;
- (void)getProcessByFileId;
- (void)requestGetProcessByFileIdFinished:(NSString *)jsonString;
- (void)requestGetProcessByFileIdFailed;

@end

@implementation LeaveApplyViewController
{
    NSArray *_flowArray;
    NSLayoutConstraint *_approvalViewConstraint;

    UIView *_departmentPickerPanel;
    UIPickerView *_departmentPickerView;
    NSArray *_departments;  // 部门
    
    UIView *_leaveTypePickerPanel;
    UIPickerView *_leaveTypePickerView;
    NSArray *_leaveTypes;   // 请假类别
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
        
        _leaveTypes = @[@"事假", @"病假", @"年假", @"产假", @"婚假", @"丧假", @"其他"];
        _departments = [DadeAppDelegate.userInfo allDepartments];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    [self initPickerPanel];
    
    [self getProcessByFileId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"请假申请"];
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
    
    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect frame = _departmentPickerPanel.frame;
                         frame.origin.y = self.view.frame.size.height - frame.size.height;
                         _departmentPickerPanel.frame = frame;
                     } completion:^(BOOL finished) {
                     }];
    
    CGFloat maxOffsetY = self.departmentView.frame.origin.y;
    CGFloat minOffsetY = self.departmentView.frame.origin.y + self.departmentView.frame.size.height + _departmentPickerPanel.frame.size.height - self.leaveApplyScrollView.frame.size.height;
    
    if(maxOffsetY < self.leaveApplyScrollView.contentOffset.y) {
        [self.leaveApplyScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.leaveApplyScrollView.contentOffset.y < minOffsetY) {
        CGFloat scrollMaxOffsetY = self.leaveApplyScrollView.contentSize.height - self.leaveApplyScrollView.frame.size.height;
        
        self.leaveApplyScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, minOffsetY - scrollMaxOffsetY, 0.0);
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.leaveApplyScrollView.contentOffset = CGPointMake(0.0, minOffsetY);
                         }
         ];
    }
}

- (void)leaveTypeClicked
{
    // 请假类别
    
    if([self isRequesting]) {
        return;
    }
    
    [self.view endEditing:YES];
    [self removePickerPanel];

    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect frame = _leaveTypePickerPanel.frame;
                         frame.origin.y = self.view.frame.size.height - frame.size.height;
                         _leaveTypePickerPanel.frame = frame;
                     } completion:^(BOOL finished) {
                     }];
    
    CGFloat maxOffsetY = self.leaveTypeView.frame.origin.y;
    CGFloat minOffsetY = self.leaveTypeView.frame.origin.y + self.leaveTypeView.frame.size.height + _leaveTypePickerPanel.frame.size.height - self.leaveApplyScrollView.frame.size.height;
    
    if(maxOffsetY < self.leaveApplyScrollView.contentOffset.y) {
        [self.leaveApplyScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.leaveApplyScrollView.contentOffset.y < minOffsetY) {
        CGFloat scrollMaxOffsetY = self.leaveApplyScrollView.contentSize.height - self.leaveApplyScrollView.frame.size.height;
        
        self.leaveApplyScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, minOffsetY - scrollMaxOffsetY, 0.0);
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.leaveApplyScrollView.contentOffset = CGPointMake(0.0, minOffsetY);
                         }
         ];
    }
}

- (void)doneDepartmentClicked
{
    NSString *department = [_departments objectAtIndex:[_departmentPickerView selectedRowInComponent:0]];
    if(![department isEqualToString:self.departmentLabel.text]) {
        self.departmentLabel.text = department;
        
        // 部门选择改变时，将部门和职位也同时改变
        NSInteger orgIndex = [_departments indexOfObject:self.departmentLabel.text];
        OrganizationInfo *orgInfo = DadeAppDelegate.userInfo.organizationArray[orgIndex];
        self.departmentLabel.text = orgInfo.department;
        self.positionLabel.text = orgInfo.gradeName;
        
        // 重新查询文件审批流程
        [self getProcessByFileId];
    }
    
    [self removePickerPanel];
    
    self.leaveApplyScrollView.contentInset = UIEdgeInsetsZero;
    
    CGFloat scrollMaxOffsetY = self.leaveApplyScrollView.contentSize.height - self.leaveApplyScrollView.frame.size.height;
    if(self.leaveApplyScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            self.leaveApplyScrollView.contentOffset = CGPointZero;
        } else {
            self.leaveApplyScrollView.contentOffset = CGPointMake(0.0, scrollMaxOffsetY);
        }
    }
}

- (void)doneLeaveTypeClicked
{
    self.leaveTypeLabel.text = [_leaveTypes objectAtIndex:[_leaveTypePickerView selectedRowInComponent:0]];
    
    [self removePickerPanel];
    
    self.leaveApplyScrollView.contentInset = UIEdgeInsetsZero;
    
    CGFloat scrollMaxOffsetY = self.leaveApplyScrollView.contentSize.height - self.leaveApplyScrollView.frame.size.height;
    if(self.leaveApplyScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            self.leaveApplyScrollView.contentOffset = CGPointZero;
        } else {
            self.leaveApplyScrollView.contentOffset = CGPointMake(0.0, scrollMaxOffsetY);
        }
    }
}

- (IBAction)reportButtonClicked:(UIButton *)button
{
    // 呈报
    
    if([self isRequesting]) {
        return;
    }
    
    [self saveLeaveApplication];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.leaveDateTextField isFirstResponder]) {
        maxOffsetY = self.leaveDateView.frame.origin.y;
        minOffsetY = self.leaveDateView.frame.origin.y + self.leaveDateView.frame.size.height + keyboardFrame.size.height - self.leaveApplyScrollView.frame.size.height;
    } else if([self.leaveDaysTextField isFirstResponder]) {
        maxOffsetY = self.leaveDaysView.frame.origin.y;
        minOffsetY = self.leaveDaysView.frame.origin.y + self.leaveDaysView.frame.size.height + keyboardFrame.size.height - self.leaveApplyScrollView.frame.size.height;
    } else if([self.contentTextView isFirstResponder]) {
        maxOffsetY = self.contentView.frame.origin.y;
        minOffsetY = self.contentView.frame.origin.y + self.contentView.frame.size.height + keyboardFrame.size.height - self.leaveApplyScrollView.frame.size.height;
    } else if([self.explainTextView isFirstResponder]) {
        maxOffsetY = self.explainView.frame.origin.y;
        minOffsetY = self.explainView.frame.origin.y + self.explainView.frame.size.height + keyboardFrame.size.height - self.leaveApplyScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.leaveApplyScrollView.contentOffset.y) {
        [self.leaveApplyScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.leaveApplyScrollView.contentOffset.y < minOffsetY) {
        CGFloat scrollMaxOffsetY = self.leaveApplyScrollView.contentSize.height - self.leaveApplyScrollView.frame.size.height;
        
        self.leaveApplyScrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, minOffsetY - scrollMaxOffsetY, 0.0);
        [UIView animateWithDuration:animationDuration
                         animations:^{
                             self.leaveApplyScrollView.contentOffset = CGPointMake(0.0, minOffsetY);
                         }
         ];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    self.leaveApplyScrollView.contentInset = UIEdgeInsetsZero;
    
    CGFloat scrollMaxOffsetY = self.leaveApplyScrollView.contentSize.height - self.leaveApplyScrollView.frame.size.height;
    if(self.leaveApplyScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            [self.leaveApplyScrollView setContentOffset:CGPointZero animated:YES];
        } else {
            [self.leaveApplyScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
        }
    }
}

- (void)dismissKeyboard
{
    if([self.contentTextView isFirstResponder]) {
        [self.contentTextView resignFirstResponder];
    } else if([self.explainTextView isFirstResponder]) {
        [self.explainTextView resignFirstResponder];
    }
}

#pragma mark - Private Methods
- (void)initView
{
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.subjectLabel.preferredMaxLayoutWidth = self.subjectLabel.bounds.size.width;
        self.senderLabel.preferredMaxLayoutWidth = self.senderLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
        self.positionLabel.preferredMaxLayoutWidth = self.positionLabel.bounds.size.width;
    }
    
    if(!_approvalViewConstraint) {
        _approvalViewConstraint = [NSLayoutConstraint constraintWithItem:self.approvalView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:0.0];
        [self.approvalView addConstraint:_approvalViewConstraint];
    }
    
    _approvalView.alpha = 0.0;

    OrganizationInfo *orgInfo = DadeAppDelegate.userInfo.organizationArray[0];
    self.subjectLabel.text = DadeAppDelegate.userInfo.staffName;
    self.senderLabel.text = DadeAppDelegate.userInfo.staffName;
    self.departmentLabel.text = orgInfo.department;
    self.positionLabel.text = orgInfo.gradeName;
    self.leaveTypeLabel.text = [_leaveTypes objectAtIndex:0];
    
    self.departmentLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(departmentClicked)];
    [self.departmentLabel addGestureRecognizer:tapGestureRecognizer1];
    self.leaveTypeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leaveTypeClicked)];
    [self.leaveTypeLabel addGestureRecognizer:tapGestureRecognizer2];
    
    self.departmentArrowImageView.image = [UIImage imageNamed:@"down_arrow"];
    self.leaveTypeArrowImageView.image = [UIImage imageNamed:@"down_arrow"];

    [self.reportButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.reportButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.reportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIToolbar *inputAccessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, INPUT_ACCESSORY_VIEW_HEIGHT)];
    inputAccessoryView.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    inputAccessoryView.items = buttonArray;
    self.contentTextView.inputAccessoryView = inputAccessoryView;
    self.explainTextView.inputAccessoryView = inputAccessoryView;
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.leaveDateTextField.text] isEqualToString:@""]) {
        [self showAlert:@"请假日期不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.leaveDaysTextField.text] isEqualToString:@""]) {
        [self showAlert:@"请假天数不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.contentTextView.text] isEqualToString:@""]) {
        [self showAlert:@"内容不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.explainTextView.text] isEqualToString:@""]) {
        [self showAlert:@"审批流转说明不能为空"];
        
        return NO;
    }
    
    if(![Util isValidDate:self.leaveDateTextField.text]) {
        [self showAlert:@"请假日期不合法"];
        
        return NO;
    }
    
    if(![Util isValidNumber:self.leaveDaysTextField.text]) {
        [self showAlert:@"请假天数不合法"];
        
        return NO;
    }
    
    return YES;
}

- (void)updateApprovalView
{
    CGFloat flowHeight = 50.0;

    if(_flowArray.count > 0) {
        _approvalViewConstraint.constant = _flowArray.count * flowHeight + 15.0;
        _approvalView.alpha = 1.0;
    } else {
        _approvalViewConstraint.constant = 0.0;
        _approvalView.alpha = 0.0;
    }

    [self.approvalView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat originY = 0.0;
    for(NSDictionary *flow in _flowArray) {
        UIView *flowView = [[UIView alloc] initWithFrame:CGRectMake(0.0, originY, self.approvalView.frame.size.width, flowHeight)];
        flowView.backgroundColor = [UIColor clearColor];
        
        UILabel *staffLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, flowView.frame.size.width, flowHeight / 2)];
        staffLabel.backgroundColor = [UIColor clearColor];
        staffLabel.font = FONT(14.0);
        staffLabel.textColor = [UIColor blackColor];
        staffLabel.text = [NSString stringWithFormat:@"审批人员：%@ %@", [flow stringForKey:@"grade"], [flow stringForKey:@"staff_name"]];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, staffLabel.frame.origin.y + staffLabel.frame.size.height, staffLabel.frame.size.width, staffLabel.frame.size.height)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = FONT(14.0);
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = [NSString stringWithFormat:@"审核：%@", [flow stringForKey:@"content"]];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, flowView.frame.size.height - 0.5, flowView.frame.size.width, 0.5)];
        lineView.backgroundColor = [UIColor blackColor];
        
        [flowView addSubview:staffLabel];
        [flowView addSubview:nameLabel];
        [flowView addSubview:lineView];
        
        [self.approvalView addSubview:flowView];
        
        originY += flowHeight;
    }
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
    
    if(!_leaveTypePickerPanel || !_leaveTypePickerView) {
        UIView *pickerPanel = [[UIView alloc] initWithFrame:CGRectMake(0.0, DEVICE_HEIGHT, DEVICE_WIDTH, PICKER_VIEW_HEIGHT + TOOLBAR_HEIGHT)];
        pickerPanel.backgroundColor = [UIColor whiteColor];
        
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, pickerPanel.frame.size.width, TOOLBAR_HEIGHT)];
        toolbar.barStyle = UIBarStyleDefault;
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(doneLeaveTypeClicked)];
        NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
        toolbar.items = buttonArray;
        
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, TOOLBAR_HEIGHT, pickerPanel.frame.size.width, PICKER_VIEW_HEIGHT)];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.showsSelectionIndicator = YES;
        
        [pickerPanel addSubview:toolbar];
        [pickerPanel addSubview:pickerView];
        [self.view addSubview:pickerPanel];
        
        _leaveTypePickerView = pickerView;
        _leaveTypePickerPanel = pickerPanel;
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
    
    if(_leaveTypePickerPanel) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             CGRect frame = _leaveTypePickerPanel.frame;
                             frame.origin.y = self.view.frame.size.height;
                             _leaveTypePickerPanel.frame = frame;
                         }
                         completion:NULL
         ];
    }
}

- (void)saveLeaveApplication
{
    if([self checkValidity]) {
        [self startLoading];
        
//        leavesTypeId：请假类型
//        leavesTypeName：请假类型名称
//        leavesTypeContent：请假原因
//        leavesDate：请假日期
//        content：内容
//        exaContent：流转说明
//        orgId：组织架构Id
//        depOrgId：部门组织架构ID
//        userId：用户Id
//        ruzhiDate：请假天数
        
        NSString *leavesTypeId = [NSString stringWithFormat:@"%i", (int)[_leaveTypes indexOfObject:self.leaveTypeLabel.text] + 1];
        NSInteger orgIndex = [_departments indexOfObject:self.departmentLabel.text];
        OrganizationInfo *orgInfo = DadeAppDelegate.userInfo.organizationArray[orgIndex];
        
        NSString *postString = [NSString stringWithFormat:@"{\"leavesTypeId\":\"%@\",\"leavesTypeName\":\"%@\",\"leavesTypeContent\":\"\",\"leavesDate\":\"%@\",\"content\":\"%@\",\"exaContent\":\"%@\",\"orgId\":\"%@\",\"depOrgId\":\"%@\",\"userId\":\"%@\",\"ruzhiDate\":\"%@\"}", leavesTypeId, self.leaveTypeLabel.text, self.leaveDateTextField.text, self.contentTextView.text, self.explainTextView.text, orgInfo.orgId, orgInfo.depOrgId, DadeAppDelegate.userInfo.staffId, self.leaveDaysTextField.text];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:SAVE_LEAVE_APPLICATION_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestSaveLeaveApplicationFinished:) didFailSelector:@selector(requestSaveLeaveApplicationFailed)];
    }
}

- (void)requestSaveLeaveApplicationFinished:(NSString *)jsonString
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

- (void)requestSaveLeaveApplicationFailed
{
    [self stopLoading];
}

- (void)getProcessByFileId
{
    [self startLoading];
    
//    fileTypeId：（请假申请：113，未打卡说明：114）
//    orgid：组织架构Id
//    qyid：企业ID

    NSInteger orgIndex = [_departments indexOfObject:self.departmentLabel.text];
    OrganizationInfo *orgInfo = DadeAppDelegate.userInfo.organizationArray[orgIndex];
    
    NSString *postString = [NSString stringWithFormat:@"{\"fileTypeId\":\"113\",\"orgid\":\"%@\",\"qyid\":\"%@\"}", orgInfo.orgId, orgInfo.qyId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_PROCESS_BY_FILE_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetProcessByFileIdFinished:) didFailSelector:@selector(requestGetProcessByFileIdFailed)];
}

- (void)requestGetProcessByFileIdFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _flowArray = [[NSArray alloc] initWithArray:jsonArray];
        [self updateApprovalView];
    }
}

- (void)requestGetProcessByFileIdFailed
{
    [self stopLoading];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(scrollView == self.leaveApplyScrollView) {
        self.leaveApplyScrollView.contentInset = UIEdgeInsetsZero;
        
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
    if(textField == self.leaveDateTextField) {
        [self.leaveDateTextField resignFirstResponder];
    } else if(textField == self.leaveDaysTextField) {
        [self.leaveDaysTextField resignFirstResponder];
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
    } else if(textView == self.explainTextView) {
        if([Util isEmptyString:self.explainTextView.text]) {
            self.explainPlaceholderLabel.alpha = 1.0;
        } else {
            self.explainPlaceholderLabel.alpha = 0.0;
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
    if(pickerView == _departmentPickerView) {
        return _departments.count;
    } else {
        return _leaveTypes.count;
    }
}

#pragma mark - UIPickerViewDelegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if(pickerView == _departmentPickerView) {
        return [_departments objectAtIndex:row];
    } else {
        return [_leaveTypes objectAtIndex:row];
    }
}

@end
