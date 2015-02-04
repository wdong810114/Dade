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

- (void)showNoticeViewById;
- (void)requestShowNoticeViewByIdFinished:(ASIHTTPRequest *)request;
- (void)requestShowNoticeViewByIdFailed:(ASIHTTPRequest *)request;
- (void)showNoticeFlowInfoList;
- (void)requestShowNoticeFlowInfoListFinished:(ASIHTTPRequest *)request;
- (void)requestShowNoticeFlowInfoListFailed:(ASIHTTPRequest *)request;

@end

@implementation NoticeDetailViewController

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

#pragma mark - Private Methods
- (void)initView
{
    self.noticeDetailScrollView.backgroundColor = COLOR(0xf5,0xf5,0xf5);
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.subjectLabel.preferredMaxLayoutWidth = self.subjectLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
        self.quartersLabel.preferredMaxLayoutWidth = self.quartersLabel.bounds.size.width;
        self.undertakerLabel.preferredMaxLayoutWidth = self.undertakerLabel.bounds.size.width;
        self.recipientsLabel.preferredMaxLayoutWidth = self.recipientsLabel.bounds.size.width;
        self.contentLabel.preferredMaxLayoutWidth = self.contentLabel.bounds.size.width;
    }
}

- (void)showNoticeViewById
{
    [self addLoadingView];
    
//    id ：文件主表Id
    
    NSString *postString = [NSString stringWithFormat:@"{id:'%@'}", self.noticeId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:SHOW_NOTICE_VIEW_BY_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestShowNoticeViewByIdFinished:) didFailSelector:@selector(requestShowNoticeViewByIdFailed:)];
}

- (void)requestShowNoticeViewByIdFinished:(ASIHTTPRequest *)request
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
        self.quartersLabel.text = [jsonDict stringForKey:@"orgName"];
        self.undertakerLabel.text = [jsonDict stringForKey:@"undertake"];
        self.contentLabel.text = [jsonDict stringForKey:@"content"];
    }
    
    [self requestDidFinish:request];
}

- (void)requestShowNoticeViewByIdFailed:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    [self requestDidFail:request];
}

- (void)showNoticeFlowInfoList
{
    [self addLoadingView];
    
//    fileinfoId：文件主表Id
//    filetypeid：文件类型ID
//    userId：当前登录人Id
    
    NSString *postString = [NSString stringWithFormat:@"{fileinfoId:'%@',filetypeid:'%@',userId:'%@'}", self.noticeId, self.fileTypeId, DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:SHOW_NOTICE_FLOW_INFO_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestShowNoticeFlowInfoListFinished:) didFailSelector:@selector(requestShowNoticeFlowInfoListFailed:)];
}

- (void)requestShowNoticeFlowInfoListFinished:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        NSMutableString *recipients = [[NSMutableString alloc] init];
        for(NSDictionary *infoDict in jsonArray) {
            NSString *recipient = [infoDict stringForKey:@"receipt"];
            [recipients appendFormat:@"%@;", [Util trimString:recipient]];
        }
        
        self.recipientsLabel.text = recipients;
    }
    
    [self requestDidFinish:request];
}

- (void)requestShowNoticeFlowInfoListFailed:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self removeLoadingView];
    }
    
    [self requestDidFail:request];
}

@end
