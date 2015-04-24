//
//  MailDetailViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-26.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "MailDetailViewController.h"

#import "MailReplyViewController.h"

@interface MailDetailViewController ()

- (void)initView;

- (void)queryMailInfoById;
- (void)requestQueryMailInfoByIdFinished:(NSString *)jsonString;
- (void)requestQueryMailInfoByIdFailed;

@end

@implementation MailDetailViewController
{
    CGPoint _scrollViewContentOffset;   // 解决iOS6下bug
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self queryMailInfoById];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.mailDetailScrollView.contentOffset = CGPointZero;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        _scrollViewContentOffset = self.mailDetailScrollView.contentOffset;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.mailDetailScrollView.contentOffset = _scrollViewContentOffset;
    }
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

- (IBAction)replyButtonClicked:(UIButton *)button
{
    // 回复
    
    if([self isRequesting]) {
        return;
    }
    
    MailReplyViewController *viewController = [[MailReplyViewController alloc] initWithNibName:@"MailReplyViewController" bundle:nil];
    viewController.subject = self.subjectLabel.text;
    viewController.mailId = self.mailId;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Private Methods
- (void)initView
{
    self.mailDetailScrollView.backgroundColor = COLOR(0xf5,0xf5,0xf5);
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.subjectLabel.preferredMaxLayoutWidth = self.subjectLabel.bounds.size.width;
        self.senderLabel.preferredMaxLayoutWidth = self.senderLabel.bounds.size.width;
        self.recipientsLabel.preferredMaxLayoutWidth = self.recipientsLabel.bounds.size.width;
        self.timeLabel.preferredMaxLayoutWidth = self.timeLabel.bounds.size.width;
        self.contentLabel.preferredMaxLayoutWidth = self.contentLabel.bounds.size.width;
    }

    [self.replyButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.replyButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.replyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)queryMailInfoById
{
    [self startLoading];
    
//    mailInfoId：邮件表主键Id
//    userId：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{\"mailInfoId\":\"%@\",\"userId\":\"%@\"}", self.mailId, DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_MAIL_INFO_BY_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryMailInfoByIdFinished:) didFailSelector:@selector(requestQueryMailInfoByIdFailed)];
}

- (void)requestQueryMailInfoByIdFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        self.subjectLabel.text = [jsonDict stringForKey:@"displayvalue"];
        self.senderLabel.text = [jsonDict stringForKey:@"mailStaffname"];
        self.recipientsLabel.text = [jsonDict stringForKey:@"staffNames"];
        self.timeLabel.text = [jsonDict stringForKey:@"operationdate"];
        self.contentLabel.text = [jsonDict stringForKey:@"content"];
    }
}

- (void)requestQueryMailInfoByIdFailed
{
    [self stopLoading];
}

@end
