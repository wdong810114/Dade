//
//  WorkContactListReplyViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-10.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "WorkContactListReplyViewController.h"

#import "WorkContactListEvaluateViewController.h"

@interface WorkContactListReplyViewController ()

- (void)initView;
- (BOOL)checkValidity;
- (void)updateFlowListView;

- (void)queryGzlxdFlowList;
- (void)requestQueryGzlxdFlowListFinished:(NSString *)jsonString;
- (void)requestQueryGzlxdFlowListFailed;
- (void)replyTodoWork;
- (void)requestReplyTodoWorkFinished:(NSString *)jsonString;
- (void)requestReplyTodoWorkFailed;
- (void)endTodoWord;
- (void)requestEndTodoWordFinished:(NSString *)jsonString;
- (void)requestEndTodoWordFailed;

@end

@implementation WorkContactListReplyViewController
{
    NSMutableArray *_flowArray;
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
    
    [self queryGzlxdFlowList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"回复内容"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
    if([self.workType isEqualToString:@"1"]) {
        if(!self.isEnd) {
            [self setRightBarButtonItem:@selector(endClicked:) title:@"完结"];
        }
    } else if([self.workType isEqualToString:@"2"]) {
        if(self.isEnd) {
            [self setRightBarButtonItem:@selector(evaluateClicked:) title:@"评价"];
        }
    }
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

- (void)endClicked:(UIButton *)button
{
    // 完结
    
    if([self isRequesting]) {
        return;
    }
    
    [self endTodoWord];
}

- (void)evaluateClicked:(UIButton *)button
{
    // 评价
    
    if([self isRequesting]) {
        return;
    }
    
    WorkContactListEvaluateViewController *viewController = [[WorkContactListEvaluateViewController alloc] initWithNibName:@"WorkContactListEvaluateViewController" bundle:nil];
    viewController.workId = self.workId;
    viewController.relationId = self.relationId;
    viewController.isLastEvaluate = self.isLastEvaluate;
    viewController.evaluateScore = self.evaluateScore;
    viewController.evaluateContent = self.evaluateContent;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)replyButtonClicked:(UIButton *)button
{
    // 回复
    
    if([self isRequesting]) {
        return;
    }
    
    [self replyTodoWork];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.contentTextView isFirstResponder]) {
        maxOffsetY = self.contentView.frame.origin.y;
        minOffsetY = self.contentView.frame.origin.y + self.contentView.frame.size.height + keyboardFrame.size.height - self.replyScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.replyScrollView.contentOffset.y) {
        [self.replyScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.replyScrollView.contentOffset.y < minOffsetY) {
        [self.replyScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat scrollMaxOffsetY = self.replyScrollView.contentSize.height - self.replyScrollView.frame.size.height;
    if(self.replyScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            [self.replyScrollView setContentOffset:CGPointZero animated:YES];
        } else {
            [self.replyScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
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
    [self.replyButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.replyButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.replyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
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
    if([[Util trimString:self.contentTextView.text] isEqualToString:@""]) {
        [self showAlert:@"内容不能为空"];
        
        return NO;
    }
    
    return YES;
}

- (void)updateFlowListView
{
    CGFloat totalHeight = 0.0;
    
    for(NSDictionary *flow in _flowArray) {
        NSString *content = [flow stringForKey:@"content"];
        CGFloat contentHeight = [Util sizeOfString:content font:FONT(14.0) constrainedToSize:CGSizeMake(self.flowListView.frame.size.width, 1000.0)].height;
        CGFloat cellHeight = 15.0 + 30.0 + 30.0 + contentHeight + 8.0;
        
        UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0.0, totalHeight, self.flowListView.frame.size.width, cellHeight)];
        cellView.backgroundColor = [UIColor clearColor];
        
        // 上半部分
        UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 15.0, cellView.frame.size.width, 30.0)];
        topView.backgroundColor = [UIColor whiteColor];
        
        UILabel *senderLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, 130.0, topView.frame.size.height)];
        senderLabel.backgroundColor = [UIColor clearColor];
        senderLabel.font = FONT(14.0);
        senderLabel.textColor = [UIColor blackColor];
        senderLabel.text = [NSString stringWithFormat:@"发件人：%@", [flow stringForKey:@"sendName"]];
        
        UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(senderLabel.frame.origin.x + senderLabel.frame.size.width, 0.0, 150.0, topView.frame.size.height)];
        dateLabel.backgroundColor = [UIColor clearColor];
        dateLabel.font = FONT(14.0);
        dateLabel.textColor = [UIColor blackColor];
        dateLabel.text = [flow stringForKey:@"operationdate"];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, topView.frame.size.height - 0.5, topView.frame.size.width, 0.5)];
        lineView.backgroundColor = [UIColor lightGrayColor];
        
        [topView addSubview:senderLabel];
        [topView addSubview:dateLabel];
        [topView addSubview:lineView];
        
        // 下半部分
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0.0, topView.frame.origin.y + topView.frame.size.height, topView.frame.size.width, cellView.frame.size.height - (topView.frame.origin.y + topView.frame.size.height))];
        bottomView.backgroundColor = [UIColor whiteColor];
        
        UILabel *cTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, 0.0, 100.0, 30.0)];
        cTitleLabel.backgroundColor = [UIColor clearColor];
        cTitleLabel.font = FONT(14.0);
        cTitleLabel.textColor = [UIColor blackColor];
        cTitleLabel.text = @"内容：";
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, cTitleLabel.frame.origin.y + cTitleLabel.frame.size.height, bottomView.frame.size.width - 10.0, contentHeight)];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.numberOfLines = 0;
        titleLabel.font = FONT(14.0);
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.text = [flow stringForKey:@"content"];
        
        [bottomView addSubview:cTitleLabel];
        [bottomView addSubview:titleLabel];
        
        [cellView addSubview:topView];
        [cellView addSubview:bottomView];
        [self.flowListView addSubview:cellView];

        totalHeight += cellHeight;
    }
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.flowListView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:totalHeight];
    [self.flowListView addConstraint:constraint];

}

- (void)queryGzlxdFlowList
{
    [self startLoading];
    
//    workId：工作联系单Id
//    staffId：登录人员ID
//    receiptId：收件人ID
    
    NSString *postString = [NSString stringWithFormat:@"{\"workId\":\"%@\",\"staffId\":\"%@\",\"receiptId\":\"%@\"}", self.workId, DadeAppDelegate.userInfo.staffId, self.recipientId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_GZLXD_FLOW_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryGzlxdFlowListFinished:) didFailSelector:@selector(requestQueryGzlxdFlowListFailed)];
}

- (void)requestQueryGzlxdFlowListFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _flowArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self updateFlowListView];
    }
}

- (void)requestQueryGzlxdFlowListFailed
{
    [self stopLoading];
}

- (void)replyTodoWork
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        [self startLoading];
        
//    gzlxdtype：工作联系单类型（1：待办；2监督）
//    workId：工作联系单Id
//    staffId：登录人员ID
//    receiptId：收件人ID
//    content：回复内容
        
        NSString *postString = [NSString stringWithFormat:@"{\"gzlxdtype\":\"%@\",\"workId\":\"%@\",\"staffId\":\"%@\",\"receiptId\":\"%@\",\"content\":\"%@\"}", self.workType, self.workId, DadeAppDelegate.userInfo.staffId, self.recipientId, self.contentTextView.text];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:REPLY_TODO_WORK_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestReplyTodoWorkFinished:) didFailSelector:@selector(requestReplyTodoWorkFailed)];
    }
}

- (void)requestReplyTodoWorkFinished:(NSString *)jsonString
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

- (void)requestReplyTodoWorkFailed
{
    [self stopLoading];
}

- (void)endTodoWord
{
    [self.view endEditing:YES];
    
    [self startLoading];
    
//    noticeStaffId：工作联系单用户关系ID
    
    NSString *postString = [NSString stringWithFormat:@"{\"noticeStaffId\":\"%@\"}", self.relationId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:END_TODO_WORD_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestEndTodoWordFinished:) didFailSelector:@selector(requestEndTodoWordFailed)];
}

- (void)requestEndTodoWordFinished:(NSString *)jsonString
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

- (void)requestEndTodoWordFailed
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
    if(textView == self.contentTextView) {
        if([Util isEmptyString:self.contentTextView.text]) {
            self.placeholderLabel.alpha = 1.0;
        } else {
            self.placeholderLabel.alpha = 0.0;
        }
    }
}

@end
