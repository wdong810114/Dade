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
        self.subjectLabel.text = [jsonDict stringForKey:@"displayvalue"];
        self.departmentLabel.text = [jsonDict stringForKey:@"depname"];
        self.quartersLabel.text = [jsonDict stringForKey:@"orgName"];
        self.undertakerLabel.text = [jsonDict stringForKey:@"undertake"];
        self.contentLabel.text = [jsonDict stringForKey:@"content"];
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
        NSMutableString *recipients = [[NSMutableString alloc] init];
        for(NSDictionary *infoDict in jsonArray) {
            NSString *recipient = [infoDict stringForKey:@"receipt"];
            [recipients appendFormat:@"%@;", [Util trimString:recipient]];
        }
        
        self.recipientsLabel.text = recipients;
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
