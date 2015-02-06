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
- (void)updateApprovalView;
- (NSString *)getFlowCode;

- (void)getIncomeViewById;
- (void)requestGetIncomeViewByIdFinished:(ASIHTTPRequest *)request;
- (void)requestGetIncomeViewByIdFailed:(ASIHTTPRequest *)request;
- (void)getDateFileTextById;
- (void)requestGetDateFileTextByIdFinished:(ASIHTTPRequest *)request;
- (void)requestGetDateFileTextByIdFailed:(ASIHTTPRequest *)request;
- (void)getFlowPathByFileIdInTable;
- (void)requestGetFlowPathByFileIdInTableFinished:(ASIHTTPRequest *)request;
- (void)requestGetFlowPathByFileIdInTableFailed:(ASIHTTPRequest *)request;
- (void)getNowFlowInfoByFlowId;
- (void)requestGetNowFlowInfoByFlowIdFinished:(ASIHTTPRequest *)request;
- (void)requestGetNowFlowInfoByFlowIdFailed:(ASIHTTPRequest *)request;
- (void)approvalFileInfo:(NSInteger)type;
- (void)requestApprovalFileInfoFinished:(ASIHTTPRequest *)request;
- (void)requestApprovalFileInfoFailed:(ASIHTTPRequest *)request;

@end

@implementation TodoNotPunchExplainDetailViewController
{
    NSString *_flowEndId;
    NSArray *_flowArray;
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
    [self getNowFlowInfoByFlowId];
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

- (IBAction)verifyButtonClicked:(UIButton *)button
{
    // 审核
    
    if([self isRequesting]) {
        return;
    }
    
    [self approvalFileInfo:0];
}

- (IBAction)retreatButtonClicked:(UIButton *)button
{
    // 退回
    
    if([self isRequesting]) {
        return;
    }
    
    [self approvalFileInfo:1];
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
    
    [self.verifyButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.verifyButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.verifyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.retreatButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.retreatButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.retreatButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
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

- (void)updateApprovalView
{
    static const CGFloat kFlowHeight = 90.0;
    
    NSLayoutConstraint *leftLineConstraint = [NSLayoutConstraint constraintWithItem:self.approvalView
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1
                                                                           constant:[_flowArray count] * kFlowHeight];
    [self.approvalView addConstraint:leftLineConstraint];
    
    CGFloat originY = 0.0;
    for(NSDictionary *flow in _flowArray) {
        UIView *flowView = [[UIView alloc] initWithFrame:CGRectMake(0.0, originY, self.approvalView.frame.size.width, kFlowHeight)];
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
        
        originY += kFlowHeight;
    }
}

- (NSString *)getFlowCode
{
    for(NSDictionary *flow in _flowArray) {
        if([_flowEndId isEqualToString:[flow stringForKey:@"id"]]) {
            return [flow stringForKey:@"flowcode"];
        }
    }
    
    return @"";
}

- (void)getIncomeViewById
{
    [self addLoadingView];
    
//    id：文件主表Id
    
    NSString *postString = [NSString stringWithFormat:@"{id:'%@'}", self.todoId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_INCOME_VIEW_BY_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetIncomeViewByIdFinished:) didFailSelector:@selector(requestGetIncomeViewByIdFailed:)];
}

- (void)requestGetIncomeViewByIdFinished:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        self.subjectLabel.text = [jsonDict stringForKey:@"displayvalue"];
        self.departmentLabel.text = [jsonDict stringForKey:@"depname"];
        self.contentLabel.text = [jsonDict stringForKey:@"content"];
    }
    
    [self requestDidFinish:request];
}

- (void)requestGetIncomeViewByIdFailed:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    [self requestDidFail:request];
}

- (void)getDateFileTextById
{
    [self addLoadingView];
    
//    fileId：文件主表Id
//    fileTypeId：文件类型ID
    
    NSString *postString = [NSString stringWithFormat:@"{fileId:'%@',fileTypeId:'114'}", self.todoId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_DATE_FILE_TEXT_BY_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetDateFileTextByIdFinished:) didFailSelector:@selector(requestGetDateFileTextByIdFailed:)];
}

- (void)requestGetDateFileTextByIdFinished:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        self.numberLabel.text = [jsonDict stringForKey:@"char1"];
        self.dateLabel.text = [jsonDict stringForKey:@"char2"];
    }
    
    [self requestDidFinish:request];
}

- (void)requestGetDateFileTextByIdFailed:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    [self requestDidFail:request];
}

- (void)getFlowPathByFileIdInTable
{
    [self addLoadingView];
    
//    fileId：文件主表Id
//    fileTypeId: 文件类型Id
    
    NSString *postString = [NSString stringWithFormat:@"{fileId:'%@',fileTypeId:'114'}", self.todoId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_FLOW_PATH_BY_FILE_ID_IN_TABLE_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetFlowPathByFileIdInTableFinished:) didFailSelector:@selector(requestGetFlowPathByFileIdInTableFailed:)];
}

- (void)requestGetFlowPathByFileIdInTableFinished:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _flowArray = [NSArray arrayWithArray:jsonArray];
        
        [self updateApprovalView];
    }
    
    [self requestDidFinish:request];
}

- (void)requestGetFlowPathByFileIdInTableFailed:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    [self requestDidFail:request];
}

- (void)getNowFlowInfoByFlowId
{
    [self addLoadingView];
    
//    flowId：文件流转表Id
    
    NSString *postString = [NSString stringWithFormat:@"{flowId:'%@'}", self.flowId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_NOW_FLOW_INFO_BY_FLOW_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetNowFlowInfoByFlowIdFinished:) didFailSelector:@selector(requestGetNowFlowInfoByFlowIdFailed:)];
}

- (void)requestGetNowFlowInfoByFlowIdFinished:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        _flowEndId = [jsonDict stringForKey:@"flowendid"];
    }
    
    [self requestDidFinish:request];
}

- (void)requestGetNowFlowInfoByFlowIdFailed:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    [self requestDidFail:request];
}

- (void)approvalFileInfo:(NSInteger)type    // 0：审核 1：退回
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        [self addLoadingView];
        
//    fileinfoId：文件主表Id
//    code：审批索引码
//    apptype：操作类型
//    approveType_value：批准操作类型
//    cirContext：审批内容
        
        NSString *flowCode = [self getFlowCode];
        NSString *approveType;
        NSString *approveTypeValue;
        if([flowCode isEqualToString:@"40"]) {
            approveType = @"1";
            approveTypeValue = (type == 0) ? @"1" : @"4";
        } else {
            approveType = (type == 0) ? @"1" : @"2";
            approveTypeValue = @"0";
        }
        
        NSString *postString = [NSString stringWithFormat:@"{fileinfoId:'%@',code:'%@',apptype:'%@',approveType_value:'%@',cirContext:'%@'}", self.todoId, flowCode, approveType, approveTypeValue, self.explainTextView.text];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:APPROVAL_FILE_INFO_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestApprovalFileInfoFinished:) didFailSelector:@selector(requestApprovalFileInfoFailed:)];
    }
}

- (void)requestApprovalFileInfoFinished:(ASIHTTPRequest *)request
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
        } else {
            [self performSelector:@selector(pop)];
        }
    }
    
    [self requestDidFinish:request];
}

- (void)requestApprovalFileInfoFailed:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    [self requestDidFail:request];
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
