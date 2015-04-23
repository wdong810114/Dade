//
//  NoticeDetailViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-22.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "NoticeDetailViewController.h"

@interface NoticeDetailViewController ()

- (void)initView;
- (void)updateUrgencyView;
- (void)updateRecipientsView;
- (BOOL)isAllRecipientsEnd;

- (void)showNoticeViewById;
- (void)requestShowNoticeViewByIdFinished:(NSString *)jsonString;
- (void)requestShowNoticeViewByIdFailed;
- (void)showNoticeFlowInfoList;
- (void)requestShowNoticeFlowInfoListFinished:(NSString *)jsonString;
- (void)requestShowNoticeFlowInfoListFailed;
- (void)isEndNotice;
- (void)requestIsEndNoticeFinished:(NSString *)jsonString;
- (void)requestIsEndNoticeFailed;

@end

@implementation NoticeDetailViewController
{
    NSLayoutConstraint *_feedbackViewConstraint;
    NSLayoutConstraint *_recipientsViewConstraint;
    NSLayoutConstraint *_sendButtonViewConstraint;
    
    BOOL _isUrgency;    // 是否显示查收确认和确认按钮 1：不显示 2：显示
    BOOL _isFeedback;
    
    NSArray *_recipientArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self showNoticeViewById];
    [self showNoticeFlowInfoList];
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

- (IBAction)sendButtonClicked:(UIButton *)button
{
    // 完结确认
    
    if([self isRequesting]) {
        return;
    }
    
    [self isEndNotice];
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

#pragma mark - Private Methods
- (void)initView
{
    self.noticeDetailScrollView.backgroundColor = COLOR(0xf5,0xf5,0xf5);
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.contentLabel.preferredMaxLayoutWidth = self.contentLabel.bounds.size.width;
        self.subjectLabel.preferredMaxLayoutWidth = self.subjectLabel.bounds.size.width;
        self.subjectWordsLabel.preferredMaxLayoutWidth = self.subjectWordsLabel.bounds.size.width;
        self.reportsLabel.preferredMaxLayoutWidth = self.reportsLabel.bounds.size.width;
        self.handleLabel.preferredMaxLayoutWidth = self.handleLabel.bounds.size.width;
        self.handlerLabel.preferredMaxLayoutWidth = self.handlerLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
    }
    
    if(!_feedbackViewConstraint) {
        _feedbackViewConstraint = [NSLayoutConstraint constraintWithItem:self.feedbackView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:0.0];
        [self.feedbackView addConstraint:_feedbackViewConstraint];
    }
    
    if(!_recipientsViewConstraint) {
        _recipientsViewConstraint = [NSLayoutConstraint constraintWithItem:self.recipientsView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:0.0];
        [self.recipientsView addConstraint:_recipientsViewConstraint];
    }
    
    if(!_sendButtonViewConstraint) {
        _sendButtonViewConstraint = [NSLayoutConstraint constraintWithItem:self.sendButtonView
                                                               attribute:NSLayoutAttributeHeight
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:nil
                                                               attribute:NSLayoutAttributeNotAnAttribute
                                                              multiplier:1
                                                                constant:0.0];
        [self.sendButtonView addConstraint:_sendButtonViewConstraint];
    }

    self.feedbackCheckImageView.image = [UIImage imageNamed:@"row_unselected_icon"];
    self.smsAlertCheckImageView.image = [UIImage imageNamed:@"row_unselected_icon"];
    
    [self.sendButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    self.feedbackLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(feedbackClicked)];
    [self.feedbackLabel addGestureRecognizer:tapGestureRecognizer];
}

- (BOOL)checkValidity
{
    if(!_isFeedback) {
        [self showAlert:@"未选中查收确认信息"];
        
        return NO;
    }
    
    if(![self isAllRecipientsEnd]) {
        [self showAlert:@"收件人有未查收确认，无法完成确认操作"];
        
        return NO;
    }
    
    return YES;
}

- (void)updateUrgencyView
{
    if(_isUrgency) {
        _feedbackViewConstraint.constant = 33.0 + 15.0;
        _sendButtonViewConstraint.constant = 44.0 + 15.0;
    } else {
        _feedbackViewConstraint.constant = 0.0;
        _sendButtonViewConstraint.constant = 0.0;
    }
}

- (void)updateRecipientsView
{
    CGFloat recipientHeight = 75.0;

    if(_recipientArray.count > 0) {
        _recipientsViewConstraint.constant = [_recipientArray count] * recipientHeight + 15.0;
    } else {
        _recipientsViewConstraint.constant = 0.0;
    }
    
    [self.recipientsView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    CGFloat originY = 0.0;
    for(NSDictionary *recipient in _recipientArray) {
        UIView *recipientView = [[UIView alloc] initWithFrame:CGRectMake(0.0, originY, self.recipientsView.frame.size.width, recipientHeight)];
        recipientView.backgroundColor = [UIColor clearColor];
        
        UILabel *recipientLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, recipientView.frame.size.width, recipientHeight / 3)];
        recipientLabel.backgroundColor = [UIColor clearColor];
        recipientLabel.font = FONT(14.0);
        recipientLabel.textColor = [UIColor blackColor];
        recipientLabel.text = [NSString stringWithFormat:@"收件人：%@", [recipient stringForKey:@"receipt"]];
        
        UILabel *stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, recipientLabel.frame.origin.y + recipientLabel.frame.size.height, recipientLabel.frame.size.width, recipientLabel.frame.size.height)];
        stateLabel.backgroundColor = [UIColor clearColor];
        stateLabel.font = FONT(14.0);
        stateLabel.textColor = [UIColor blackColor];
        NSString *transceiver = [recipient stringForKey:@"transceiver"];
        NSString *state = nil;
        if([transceiver isEqualToString:@"1"]) {
            state = @"已查看";
        } else if([transceiver isEqualToString:@"2"]) {
            state = @"已查收确认";
        } else {
            state = @"未查看";
        }
        stateLabel.text = [NSString stringWithFormat:@"类型：%@", state];
        
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, stateLabel.frame.origin.y + stateLabel.frame.size.height, recipientLabel.frame.size.width, recipientLabel.frame.size.height)];
        timeLabel.backgroundColor = [UIColor clearColor];
        timeLabel.font = FONT(14.0);
        timeLabel.textColor = [UIColor blackColor];
        timeLabel.text = [NSString stringWithFormat:@"操作时间：%@", [recipient stringForKey:@"receipttime"]];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, recipientView.frame.size.height - 0.5, recipientView.frame.size.width, 0.5)];
        lineView.backgroundColor = [UIColor blackColor];
        
        [recipientView addSubview:recipientLabel];
        [recipientView addSubview:stateLabel];
        [recipientView addSubview:timeLabel];
        [recipientView addSubview:lineView];
        
        [self.recipientsView addSubview:recipientView];
        
        originY += recipientHeight;
    }
}

- (BOOL)isAllRecipientsEnd
{
    for(NSDictionary *recipient in _recipientArray) {
        if(![[recipient stringForKey:@"transceiver"] isEqualToString:@"2"]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)showNoticeViewById
{
    [self startLoading];
    
//    id ：文件主表Id
//    userId：当前登录人Id
    
    NSString *fileinfoId = self.noticeId;
    NSString *userId = DadeAppDelegate.userInfo.staffId;
    
    NSString *postString = [NSString stringWithFormat:@"{\"id\":\"%@\",\"userId\":\"%@\"}", fileinfoId, userId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:SHOW_NOTICE_VIEW_BY_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestShowNoticeViewByIdFinished:) didFailSelector:@selector(requestShowNoticeViewByIdFailed)];
}

- (void)requestShowNoticeViewByIdFinished:(NSString *)jsonString
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        self.markYearLabel.text = [jsonDict stringForKey:@"char4"];
        self.markNumberLabel.text = [jsonDict stringForKey:@"char5"];
        self.contentLabel.text = [jsonDict stringForKey:@"content"];
        self.subjectLabel.text = [jsonDict stringForKey:@"displayvalue"];
        self.subjectWordsLabel.text = [jsonDict stringForKey:@"char2"];
        self.reportsLabel.text = [jsonDict stringForKey:@"text2"];
        self.handleLabel.text = [jsonDict stringForKey:@"char3"];
        self.handlerLabel.text = [jsonDict stringForKey:@"undertake"];
        self.departmentLabel.text = [jsonDict stringForKey:@"depname"];
        self.yearLabel.text = [jsonDict stringForKey:@"char7"];
        self.monthLabel.text = [jsonDict stringForKey:@"char8"];
        self.dayLabel.text = [jsonDict stringForKey:@"char9"];
        self.copiesLabel.text = [jsonDict stringForKey:@"char6"];
        self.alertDaysLabel.text = [jsonDict stringForKey:@"date_ph"];
        self.smsAlertCheckImageView.image = [[jsonDict stringForKey:@"phone"] isEqualToString:@"1"] ? [UIImage imageNamed:@"row_selected_icon"] : [UIImage imageNamed:@"row_unselected_icon"];
        
        _isUrgency = [[jsonDict stringForKey:@"urgency"] isEqualToString:@"2"];
        [self updateUrgencyView];
    }
}

- (void)requestShowNoticeViewByIdFailed
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
}

- (void)showNoticeFlowInfoList
{
    [self startLoading];
    
//    fileinfoId：文件主表Id
//    filetypeid：文件类型ID
//    userId：当前登录人Id
 
    NSString *fileinfoId = self.noticeId;
    NSString *filetypeid = self.fileTypeId;
    NSString *userId = DadeAppDelegate.userInfo.staffId;
    
    NSString *postString = [NSString stringWithFormat:@"{\"fileinfoId\":\"%@\",\"filetypeid\":\"%@\",\"userId\":\"%@\"}", fileinfoId, filetypeid, userId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:SHOW_NOTICE_FLOW_INFO_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestShowNoticeFlowInfoListFinished:) didFailSelector:@selector(requestShowNoticeFlowInfoListFailed)];
}

- (void)requestShowNoticeFlowInfoListFinished:(NSString *)jsonString
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _recipientArray = [[NSArray alloc] initWithArray:jsonArray];
        [self updateRecipientsView];
    }
}

- (void)requestShowNoticeFlowInfoListFailed
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
}

- (void)isEndNotice
{
    if([self checkValidity]) {
        [self startLoading];
        
//    userId：用户Id
//    fileinfoId：通知Id
        
        NSString *userId = DadeAppDelegate.userInfo.staffId;
        NSString *fileinfoId = self.noticeId;
        
        NSString *postString = [NSString stringWithFormat:@"{\"userId\":\"%@\",\"fileinfoId\":\"%@\"}", userId, fileinfoId];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:IS_END_NOTICE_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestIsEndNoticeFinished:) didFailSelector:@selector(requestIsEndNoticeFailed)];
    }
}

- (void)requestIsEndNoticeFinished:(NSString *)jsonString
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
            [[NSNotificationCenter defaultCenter] postNotificationName:DDNoticeListRefreshNotification object:nil];
            [self performSelector:@selector(pop)];
        }
    }
}

- (void)requestIsEndNoticeFailed
{
    [self stopLoading];
}

@end
