//
//  TodoNotPunchExplainDetailViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-5.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "TodoNotPunchExplainDetailViewController.h"

@interface TodoNotPunchExplainDetailViewController ()

- (void)initView;
- (BOOL)checkValidity;
- (void)updateSelectedRadio;
- (void)updateButtonsView;
- (void)updateApprovalView;

- (void)getIncomeViewById;
- (void)requestGetIncomeViewByIdFinished:(NSString *)jsonString;
- (void)requestGetIncomeViewByIdFailed;
- (void)getDateFileTextById;
- (void)requestGetDateFileTextByIdFinished:(NSString *)jsonString;
- (void)requestGetDateFileTextByIdFailed;
- (void)getFlowPathByFileIdInTable;
- (void)requestGetFlowPathByFileIdInTableFinished:(NSString *)jsonString;
- (void)requestGetFlowPathByFileIdInTableFailed;
- (void)getNowFlowInfoByFlowId;
- (void)requestGetNowFlowInfoByFlowIdFinished:(NSString *)jsonString;
- (void)requestGetNowFlowInfoByFlowIdFailed;
- (void)approvalFileInfo:(NSInteger)type;
- (void)requestApprovalFileInfoFinished:(NSString *)jsonString;
- (void)requestApprovalFileInfoFailed;

@end

@implementation TodoNotPunchExplainDetailViewController
{
    NSInteger _selectedRadio;

    NSArray *_flowArray;
    NSString *_flowCode;
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
    
    [self getIncomeViewById];
    [self getDateFileTextById];
    [self getFlowPathByFileIdInTable];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"内容详情"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

- (void)verifyButtonClicked:(UIButton *)button
{
    // 审核
    
    if([self isRequesting]) {
        return;
    }
    
    [self approvalFileInfo:0];
}

- (void)retreatButtonClicked:(UIButton *)button
{
    // 退回
    
    if([self isRequesting]) {
        return;
    }
    
    [self approvalFileInfo:1];
}

- (void)radioViewClicked:(UITapGestureRecognizer *)gestureRecognizer
{
    NSInteger tag = gestureRecognizer.view.tag;
    _selectedRadio = tag - 1000;
    
    [self updateSelectedRadio];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.explainTextView isFirstResponder]) {
        maxOffsetY = self.explainView.frame.origin.y;
        minOffsetY = self.explainView.frame.origin.y + self.explainView.frame.size.height + keyboardFrame.size.height - self.todoDetailScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.todoDetailScrollView.contentOffset.y) {
        [self.todoDetailScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.todoDetailScrollView.contentOffset.y < minOffsetY) {
        [self.todoDetailScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat scrollMaxOffsetY = self.todoDetailScrollView.contentSize.height - self.todoDetailScrollView.frame.size.height;
    if(self.todoDetailScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            [self.todoDetailScrollView setContentOffset:CGPointZero animated:YES];
        } else {
            [self.todoDetailScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
        }
    }
}

- (void)dismissKeyboard
{
    [self.explainTextView resignFirstResponder];
}

#pragma mark - Private Methods
- (void)initView
{
    self.todoDetailScrollView.backgroundColor = COLOR(0xf5,0xf5,0xf5);
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.subjectLabel.preferredMaxLayoutWidth = self.subjectLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
        self.numberLabel.preferredMaxLayoutWidth = self.numberLabel.bounds.size.width;
        self.dateLabel.preferredMaxLayoutWidth = self.dateLabel.bounds.size.width;
        self.contentLabel.preferredMaxLayoutWidth = self.contentLabel.bounds.size.width;
    }
    
    UIToolbar *inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, INPUT_ACCESSORY_VIEW_HEIGHT)];
    inputAccessoryView.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    inputAccessoryView.items = buttonArray;
    self.explainTextView.inputAccessoryView = inputAccessoryView;
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.explainTextView.text] isEqualToString:@""]) {
        [self showAlert:@"流转说明不能为空"];
        
        return NO;
    }
    
    return YES;
}

- (void)updateSelectedRadio
{
    UIView *radiosView = [self.buttonsView viewWithTag:100];
    
    for(UIView *radioView in radiosView.subviews) {
        for(UIView *subview in radioView.subviews) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *radioImageView = (UIImageView *)subview;
                if(_selectedRadio == radioView.tag - 1000) {
                    radioImageView.image = [UIImage imageNamed:@"row_selected_icon"];
                } else {
                    radioImageView.image = [UIImage imageNamed:@"row_unselected_icon"];
                }
            }
        }
    }
}

- (void)updateButtonsView
{
    if([_flowCode isEqualToString:@"40"]) {
        self.buttonsView.backgroundColor = [UIColor clearColor];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.buttonsView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:170.0];
        [self.buttonsView addConstraint:constraint];
        
        UIView *radiosView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.buttonsView.frame.size.width, 120.0)];
        radiosView.backgroundColor = [UIColor clearColor];
        radiosView.tag = 100;
        
        NSInteger radioCount = 4;
        CGFloat radioHeight = radiosView.frame.size.height / radioCount;
        CGFloat originY = 0.0;
        for(NSInteger index = 1; index <= radioCount; index++) {
            UIView *radioView = [[UIView alloc] initWithFrame:CGRectMake(0.0, originY, radiosView.frame.size.width, radioHeight)];
            radioView.backgroundColor = [UIColor clearColor];
            radioView.userInteractionEnabled = YES;
            radioView.tag = 1000 + index;
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(radioViewClicked:)];
            [radioView addGestureRecognizer:tapGestureRecognizer];
            
            UIImageView *radioImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, (radioView.frame.size.height - 18.0) / 2, 18.0, 18.0)];
            radioImageView.backgroundColor = [UIColor clearColor];
            
            UILabel *radioLabel = [[UILabel alloc] initWithFrame:CGRectMake(radioImageView.frame.origin.x + radioImageView.frame.size.width + 5.0, 0.0, radioView.frame.size.width, radioView.frame.size.height)];
            radioLabel.backgroundColor = [UIColor clearColor];
            radioLabel.font = FONT(14.0);
            radioLabel.textColor = [UIColor blackColor];
            if(index == 1) {
                radioLabel.text = @"同意";
            } else if(index == 2) {
                radioLabel.text = @"有条件同意";
            } else if(index == 3) {
                radioLabel.text = @"修改重报";
            } else {
                radioLabel.text = @"不同意";
            }
            
            [radioView addSubview:radioImageView];
            [radioView addSubview:radioLabel];
            [radiosView addSubview:radioView];
            
            originY += radioHeight;
        }
        
        UIButton *verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        verifyButton.frame = CGRectMake(5.0, radiosView.frame.origin.y + radiosView.frame.size.height + 10.0, 80.0, 40.0);
        [verifyButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
        [verifyButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
        verifyButton.titleLabel.font = FONT(16.0);
        [verifyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [verifyButton setTitle:@"批准" forState:UIControlStateNormal];
        [verifyButton addTarget:self action:@selector(verifyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.buttonsView addSubview:radiosView];
        [self.buttonsView addSubview:verifyButton];
        
        [self updateSelectedRadio];
    } else {
        self.buttonsView.backgroundColor = [UIColor whiteColor];
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.buttonsView
                                                                      attribute:NSLayoutAttributeHeight
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:nil
                                                                      attribute:NSLayoutAttributeNotAnAttribute
                                                                     multiplier:1
                                                                       constant:50.0];
        [self.buttonsView addConstraint:constraint];
        
        UIButton *verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        verifyButton.frame = CGRectMake(5.0, 5.0, 80.0, 40.0);
        [verifyButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
        [verifyButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
        verifyButton.titleLabel.font = FONT(16.0);
        [verifyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if([_flowCode isEqualToString:@"45"]) {
            [verifyButton setTitle:@"盖章" forState:UIControlStateNormal];
        } else if([_flowCode isEqualToString:@"50"]) {
            [verifyButton setTitle:@"存档" forState:UIControlStateNormal];
        } else {
            [verifyButton setTitle:@"审核" forState:UIControlStateNormal];
        }
        [verifyButton addTarget:self action:@selector(verifyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttonsView addSubview:verifyButton];
        
        if(![_flowCode isEqualToString:@"45"] && ![_flowCode isEqualToString:@"50"]) {
            UIButton *retreatButton = [UIButton buttonWithType:UIButtonTypeCustom];
            retreatButton.frame = CGRectMake(verifyButton.frame.origin.x + verifyButton.frame.size.width + 10.0, verifyButton.frame.origin.y, verifyButton.frame.size.width, verifyButton.frame.size.height);
            [retreatButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
            [retreatButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
            retreatButton.titleLabel.font = FONT(16.0);
            [retreatButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [retreatButton setTitle:@"退回" forState:UIControlStateNormal];
            [retreatButton addTarget:self action:@selector(retreatButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.buttonsView addSubview:retreatButton];
        }
    }
}

- (void)updateApprovalView
{
    CGFloat flowHeight = 90.0;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.approvalView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:[_flowArray count] * flowHeight];
    [self.approvalView addConstraint:constraint];
    
    CGFloat originY = 0.0;
    for(NSDictionary *flow in _flowArray) {
        UIView *flowView = [[UIView alloc] initWithFrame:CGRectMake(0.0, originY, self.approvalView.frame.size.width, flowHeight)];
        flowView.backgroundColor = [UIColor clearColor];
        
        UILabel *staffLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, flowView.frame.size.width, 30.0)];
        staffLabel.backgroundColor = [UIColor clearColor];
        staffLabel.font = FONT(14.0);
        staffLabel.textColor = [UIColor blackColor];
        staffLabel.text = [NSString stringWithFormat:@"审批人员：%@", [flow stringForKey:@"org_staff_Name"]];
        
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, staffLabel.frame.origin.y + staffLabel.frame.size.height, staffLabel.frame.size.width, staffLabel.frame.size.height)];
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.font = FONT(14.0);
        nameLabel.textColor = [UIColor blackColor];
        nameLabel.text = [NSString stringWithFormat:@"审核：%@", [flow stringForKey:@"flowname"]];
        
        UILabel *explainLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, nameLabel.frame.origin.y + nameLabel.frame.size.height, staffLabel.frame.size.width, staffLabel.frame.size.height)];
        explainLabel.backgroundColor = [UIColor clearColor];
        explainLabel.font = FONT(14.0);
        explainLabel.textColor = [UIColor blackColor];
        explainLabel.text = [NSString stringWithFormat:@"流转说明：%@", [flow stringForKey:@"flowexplain"]];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, flowView.frame.size.height - 0.5, flowView.frame.size.width, 0.5)];
        lineView.backgroundColor = [UIColor blackColor];
        
        [flowView addSubview:staffLabel];
        [flowView addSubview:nameLabel];
        [flowView addSubview:explainLabel];
        [flowView addSubview:lineView];
        
        [self.approvalView addSubview:flowView];
        
        originY += flowHeight;
    }
}

- (void)getIncomeViewById
{
    [self startLoading];
    
//    id：文件主表Id
    
    NSString *postString = [NSString stringWithFormat:@"{id:'%@'}", self.todoId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_INCOME_VIEW_BY_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetIncomeViewByIdFinished:) didFailSelector:@selector(requestGetIncomeViewByIdFailed)];
}

- (void)requestGetIncomeViewByIdFinished:(NSString *)jsonString
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        self.subjectLabel.text = [jsonDict stringForKey:@"displayvalue"];
        self.departmentLabel.text = [jsonDict stringForKey:@"depname"];
        self.contentLabel.text = [jsonDict stringForKey:@"content"];
    }
}

- (void)requestGetIncomeViewByIdFailed
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
}

- (void)getDateFileTextById
{
    [self startLoading];
    
//    fileId：文件主表Id
//    fileTypeId：文件类型ID
    
    NSString *postString = [NSString stringWithFormat:@"{fileId:'%@',fileTypeId:'114'}", self.todoId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_DATE_FILE_TEXT_BY_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetDateFileTextByIdFinished:) didFailSelector:@selector(requestGetDateFileTextByIdFailed)];
}

- (void)requestGetDateFileTextByIdFinished:(NSString *)jsonString
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        self.numberLabel.text = [jsonDict stringForKey:@"char1"];
        self.dateLabel.text = [jsonDict stringForKey:@"char2"];
    }
}

- (void)requestGetDateFileTextByIdFailed
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
}

- (void)getFlowPathByFileIdInTable
{
    [self startLoading];
    
//    fileId：文件主表Id
//    fileTypeId: 文件类型Id
    
    NSString *postString = [NSString stringWithFormat:@"{fileId:'%@',fileTypeId:'114'}", self.todoId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_FLOW_PATH_BY_FILE_ID_IN_TABLE_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetFlowPathByFileIdInTableFinished:) didFailSelector:@selector(requestGetFlowPathByFileIdInTableFailed)];
}

- (void)requestGetFlowPathByFileIdInTableFinished:(NSString *)jsonString
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _flowArray = [NSArray arrayWithArray:jsonArray];
        
        [self getNowFlowInfoByFlowId];
    }
}

- (void)requestGetFlowPathByFileIdInTableFailed
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
}

- (void)getNowFlowInfoByFlowId
{
    [self startLoading];
    
//    flowId：文件流转表Id
    
    NSString *postString = [NSString stringWithFormat:@"{flowId:'%@'}", self.flowId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_NOW_FLOW_INFO_BY_FLOW_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetNowFlowInfoByFlowIdFinished:) didFailSelector:@selector(requestGetNowFlowInfoByFlowIdFailed)];
}

- (void)requestGetNowFlowInfoByFlowIdFinished:(NSString *)jsonString
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        NSString *flowEndId = [jsonDict stringForKey:@"flowendid"];
        for(NSDictionary *flow in _flowArray) {
            if([flowEndId isEqualToString:[flow stringForKey:@"id"]]) {
                _flowCode = [flow stringForKey:@"flowcode"];
            }
        }
        
        [self updateButtonsView];
        [self updateApprovalView];
    }
}

- (void)requestGetNowFlowInfoByFlowIdFailed
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
}

- (void)approvalFileInfo:(NSInteger)type    // 0：审核 1：退回
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        [self startLoading];
        
//    fileinfoId：文件主表Id
//    code：审批索引码
//    apptype：操作类型
//    approveType_value：批准操作类型
//    cirContext：审批内容
        
        NSString *approveType;
        NSString *approveTypeValue;
        if([_flowCode isEqualToString:@"40"]) {
            approveType = @"1";
            approveTypeValue = [NSString stringWithFormat:@"%i", (int)_selectedRadio];
        } else if([_flowCode isEqualToString:@"45"] || [_flowCode isEqualToString:@"50"]) {
            approveType = @"1";
            approveTypeValue = @"0";
        } else {
            approveType = (type == 0) ? @"1" : @"2";
            approveTypeValue = @"0";
        }
        
        NSString *postString = [NSString stringWithFormat:@"{fileinfoId:'%@',code:'%@',apptype:'%@',approveType_value:'%@',cirContext:'%@'}", self.todoId, _flowCode, approveType, approveTypeValue, self.explainTextView.text];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:APPROVAL_FILE_INFO_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestApprovalFileInfoFinished:) didFailSelector:@selector(requestApprovalFileInfoFailed)];
    }
}

- (void)requestApprovalFileInfoFinished:(NSString *)jsonString
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
            [[NSNotificationCenter defaultCenter] postNotificationName:DDTodoListRefreshNotification object:nil];
            [self performSelector:@selector(pop)];
        }
    }
}

- (void)requestApprovalFileInfoFailed
{
    [self stopLoading];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
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
    if(textView == self.explainTextView) {
        if([Util isEmptyString:self.explainTextView.text]) {
            self.explainPlaceholderLabel.alpha = 1.0;
        } else {
            self.explainPlaceholderLabel.alpha = 0.0;
        }
    }
}

@end
