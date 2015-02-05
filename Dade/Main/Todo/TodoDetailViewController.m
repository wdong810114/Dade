//
//  TodoDetailViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-5.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "TodoDetailViewController.h"

@interface TodoDetailViewController ()

- (void)initView;

- (void)getIncomeViewById;
- (void)requestGetIncomeViewByIdFinished:(ASIHTTPRequest *)request;
- (void)requestGetIncomeViewByIdFailed:(ASIHTTPRequest *)request;

@end

@implementation TodoDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self getIncomeViewById];
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
    self.todoDetailScrollView.backgroundColor = COLOR(0xf5,0xf5,0xf5);
    
    if(!IOS_VERSION_7_OR_ABOVE) {

    }
}

- (void)getIncomeViewById
{
    [self addLoadingView];
    
//    id ：文件主表Id
    
    NSString *postString = [NSString stringWithFormat:@"{id:'%@'}", self.todoId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_INCOME_VIEW_BY_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetIncomeViewByIdFinished:) didFailSelector:@selector(requestGetIncomeViewByIdFailed:)];
}

- (void)requestGetIncomeViewByIdFinished:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {

    }

    [self requestDidFinish:request];
}

- (void)requestGetIncomeViewByIdFailed:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    [self requestDidFail:request];
}

@end
