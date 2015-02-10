//
//  WorkContactListReplyViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-10.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "WorkContactListReplyViewController.h"

@interface WorkContactListReplyViewController ()

- (void)initView;
- (BOOL)checkValidity;
- (void)updateFlowListView;

- (void)queryGzlxdFlowList;
- (void)requestQueryGzlxdFlowListFinished:(ASIHTTPRequest *)request;
- (void)requestQueryGzlxdFlowListFailed:(ASIHTTPRequest *)request;
- (void)replyTodoWork;
- (void)requestReplyTodoWorkFinished:(ASIHTTPRequest *)request;
- (void)requestReplyTodoWorkFailed:(ASIHTTPRequest *)request;
- (void)endTodoWord;
- (void)requestEndTodoWordFinished:(ASIHTTPRequest *)request;
- (void)requestEndTodoWordFailed:(ASIHTTPRequest *)request;

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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self.view endEditing:YES];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"回复内容"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
    if([self.workType isEqualToString:@"1"]) {
        [self setRightBarButtonItem:@selector(endClicked:) title:@"完结"];
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
    if([[Util trimString:self.contentTextView.text] isEqualToString:@""]) {
        [self showAlert:@"内容不能为空"];
        
        return NO;
    }
    
    return YES;
}

- (void)updateFlowListView
{
    
}

- (void)queryGzlxdFlowList
{
    [self startLoading];
    
//    workId：工作联系单Id
//    staffId：登录人员ID
//    receiptId：收件人ID
    
    NSString *postString = [NSString stringWithFormat:@"{workId:'%@',staffId:'%@',receiptId:'%@'}", self.workId, DadeAppDelegate.userInfo.staffId, self.recipientId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_GZLXD_FLOW_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryGzlxdFlowListFinished:) didFailSelector:@selector(requestQueryGzlxdFlowListFailed:)];
}

- (void)requestQueryGzlxdFlowListFinished:(ASIHTTPRequest *)request
{
    [self stopLoading];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _flowArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self updateFlowListView];
    }
    
    [self requestDidFinish:request];
}

- (void)requestQueryGzlxdFlowListFailed:(ASIHTTPRequest *)request
{
    [self stopLoading];
    
    [self requestDidFail:request];
}

- (void)replyTodoWork
{
    [self startLoading];
    
//    gzlxdtype：工作联系单类型（1：待办；2监督）
//    workId：工作联系单Id
//    staffId：登录人员ID
//    receiptId：收件人ID
//    content：回复内容
    
    NSString *postString = [NSString stringWithFormat:@"{gzlxdtype:'%@',workId:'%@',staffId:'%@',receiptId:'%@',content:'%@'}", self.workType, self.workId, DadeAppDelegate.userInfo.staffId, self.recipientId, self.contentTextView.text];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:REPLY_TODO_WORK_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestReplyTodoWorkFinished:) didFailSelector:@selector(requestReplyTodoWorkFailed:)];
}

- (void)requestReplyTodoWorkFinished:(ASIHTTPRequest *)request
{
    [self stopLoading];
    
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

- (void)requestReplyTodoWorkFailed:(ASIHTTPRequest *)request
{
    [self stopLoading];
    
    [self requestDidFail:request];
}

- (void)endTodoWord
{
    [self startLoading];
    
//    noticeStaffId：工作联系单用户关系ID
    
    NSString *postString = [NSString stringWithFormat:@"{noticeStaffId:'%@'}", self.relationId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:END_TODO_WORD_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestEndTodoWordFinished:) didFailSelector:@selector(requestEndTodoWordFailed:)];
}

- (void)requestEndTodoWordFinished:(ASIHTTPRequest *)request
{
    [self stopLoading];
    
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

- (void)requestEndTodoWordFailed:(ASIHTTPRequest *)request
{
    [self stopLoading];
    
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
    if(textView == self.contentTextView) {
        if([Util isEmptyString:self.contentTextView.text]) {
            self.placeholderLabel.alpha = 1.0;
        } else {
            self.placeholderLabel.alpha = 0.0;
        }
    }
}

@end
