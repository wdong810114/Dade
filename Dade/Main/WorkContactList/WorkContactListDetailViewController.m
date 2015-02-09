//
//  WorkContactListDetailViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-9.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "WorkContactListDetailViewController.h"

@interface WorkContactListDetailViewController ()

- (void)initView;

- (void)queryTodoWorkInfo;
- (void)requestQueryTodoWorkInfoFinished:(ASIHTTPRequest *)request;
- (void)requestQueryTodoWorkInfoFailed:(ASIHTTPRequest *)request;

@end

@implementation WorkContactListDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self queryTodoWorkInfo];
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
    self.workContactListDetailScrollView.backgroundColor = COLOR(0xf5,0xf5,0xf5);
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.senderLabel.preferredMaxLayoutWidth = self.senderLabel.bounds.size.width;
        self.statusLabel.preferredMaxLayoutWidth = self.statusLabel.bounds.size.width;
        self.operateTimeLabel.preferredMaxLayoutWidth = self.operateTimeLabel.bounds.size.width;
        self.specifiedFinishTimeLabel.preferredMaxLayoutWidth = self.specifiedFinishTimeLabel.bounds.size.width;
        self.finishTimeLabel.preferredMaxLayoutWidth = self.finishTimeLabel.bounds.size.width;
        self.subjectLabel.preferredMaxLayoutWidth = self.subjectLabel.bounds.size.width;
        self.contentLabel.preferredMaxLayoutWidth = self.contentLabel.bounds.size.width;
    }
}

- (void)queryTodoWorkInfo
{
    [self startLoading];
    
//    workId：工作联系单Id
    
    NSString *postString = [NSString stringWithFormat:@"{workId:'%@'}", self.workListId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_TODO_WORK_INFO_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryTodoWorkInfoFinished:) didFailSelector:@selector(requestQueryTodoWorkInfoFailed:)];
}

- (void)requestQueryTodoWorkInfoFinished:(ASIHTTPRequest *)request
{
    [self stopLoading];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        self.senderLabel.text = [jsonDict stringForKey:@"staffName"];
        self.statusLabel.text = ([[jsonDict stringForKey:@"stateid"] isEqualToString:@"1"]) ? @"已发" : @"草稿";
        self.operateTimeLabel.text = [jsonDict stringForKey:@"operationdate"];
        self.specifiedFinishTimeLabel.text = [jsonDict stringForKey:@"appointTime"];
        self.finishTimeLabel.text = [jsonDict stringForKey:@"enddate"];
        self.isSMSLabel.text = ([[jsonDict stringForKey:@"phone"] isEqualToString:@"1"]) ? @"是" : @"否";
        self.daysLabel.text = [jsonDict stringForKey:@"datePh"];
        self.isRemindLabel.text = ([[jsonDict stringForKey:@"bsPh"] isEqualToString:@"1"]) ? @"是" : @"否";
        self.subjectLabel.text = [jsonDict stringForKey:@"displayvalue"];
        self.contentLabel.text = [jsonDict stringForKey:@"content"];
    }
    
    [self requestDidFinish:request];
}

- (void)requestQueryTodoWorkInfoFailed:(ASIHTTPRequest *)request
{
    [self stopLoading];
    
    [self requestDidFail:request];
}

@end
