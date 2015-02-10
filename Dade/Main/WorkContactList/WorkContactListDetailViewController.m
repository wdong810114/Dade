//
//  WorkContactListDetailViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-9.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "WorkContactListDetailViewController.h"

#import "WorkContactListReplyViewController.h"

@interface WorkContactListDetailViewController ()

- (void)initView;
- (void)updateRecipientsListView;

- (void)queryTodoWorkInfo;
- (void)requestQueryTodoWorkInfoFinished:(ASIHTTPRequest *)request;
- (void)requestQueryTodoWorkInfoFailed:(ASIHTTPRequest *)request;
- (void)queryTodoNoticeList;
- (void)requestQueryTodoNoticeListFinished:(ASIHTTPRequest *)request;
- (void)requestQueryTodoNoticeListFailed:(ASIHTTPRequest *)request;

@end

@implementation WorkContactListDetailViewController
{
    CGPoint _scrollViewContentOffset;   // 解决iOS6下bug
    NSLayoutConstraint *_heightConstraint;
    
    NSMutableArray *_recipientArray;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DDWorkContactListNeedRefreshNotification
                                                  object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshView:)
                                                     name:DDWorkContactListNeedRefreshNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self queryTodoWorkInfo];
    [self queryTodoNoticeList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.workContactListDetailScrollView.contentOffset = CGPointZero;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _scrollViewContentOffset = self.workContactListDetailScrollView.contentOffset;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.workContactListDetailScrollView.contentOffset = _scrollViewContentOffset;
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

- (void)refreshView:(NSNotification *)notification
{
    [self queryTodoWorkInfo];
    [self queryTodoNoticeList];
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

- (void)updateRecipientsListView
{
    if(_heightConstraint) {
        [self.recipientsListView removeConstraint:_heightConstraint];
    }
    
    CGFloat totalHeight = [_recipientArray count] * TABLEVIEW_CELL_HEIGHT;
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.recipientsListView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:totalHeight];
    [self.recipientsListView addConstraint:constraint];
    
    [self.recipientsListView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UITableView *recipientsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.recipientsListView.frame.size.width, totalHeight) style:UITableViewStylePlain];
    recipientsTableView.backgroundView = nil;
    recipientsTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    recipientsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    recipientsTableView.scrollEnabled = NO;
    recipientsTableView.dataSource = self;
    recipientsTableView.delegate = self;
    if(IOS_VERSION_7_OR_ABOVE) {
        recipientsTableView.separatorInset = UIEdgeInsetsZero;
    }
    [self.recipientsListView addSubview:recipientsTableView];
}

- (void)queryTodoWorkInfo
{
    [self startLoading];
    
//    workId：工作联系单Id
    
    NSString *postString = [NSString stringWithFormat:@"{workId:'%@'}", self.workId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_TODO_WORK_INFO_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryTodoWorkInfoFinished:) didFailSelector:@selector(requestQueryTodoWorkInfoFailed:)];
}

- (void)requestQueryTodoWorkInfoFinished:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
    
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
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
    
    [self requestDidFail:request];
}

- (void)queryTodoNoticeList
{
    [self startLoading];
    
//    gzlxdtype：工作联系单类型（1：待办；2监督）
//    workId：工作联系单Id
//    userStaffId：登录用户名
    
    NSString *postString = [NSString stringWithFormat:@"{gzlxdtype:'%@',workId:'%@',userStaffId:'%@'}", self.workType, self.workId, DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_TODO_NOTICE_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryTodoNoticeListFinished:) didFailSelector:@selector(requestQueryTodoNoticeListFailed:)];
}

- (void)requestQueryTodoNoticeListFinished:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _recipientArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self updateRecipientsListView];
    }
    
    [self requestDidFinish:request];
}

- (void)requestQueryTodoNoticeListFailed:(ASIHTTPRequest *)request
{
    if([self isSingleRequesting]) {
        [self stopLoading];
    }
    
    [self requestDidFail:request];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_recipientArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *RecipientCellIdentifier = @"RecipientCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:RecipientCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RecipientCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = FONT(14.0);
    }
    
    NSDictionary *recipient = [_recipientArray objectAtIndex:indexPath.row];
    NSString *isend = [recipient stringForKey:@"isend"];
    NSString *status = @"";
    if([isend isEqualToString:@"0"]) {
        status = @"未读";
    } else if([isend isEqualToString:@"1"]) {
        status = @"已读";
    } else if([isend isEqualToString:@"2"]) {
        status = @"完结";
    } else if([isend isEqualToString:@"3"]) {
        status = @"拒绝";
    } else if([isend isEqualToString:@"4"]) {
        status = @"关闭";
    } else {
        status = @"未知";
    }
    NSString *name = [Util trimString:[recipient stringForKey:@"staffName"]];
    cell.textLabel.text = [NSString stringWithFormat:@"(%@)%@—%@", status, name, [recipient stringForKey:@"sjdate"]];
    
    return cell;
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self isRequesting]) {
        return;
    }
    
    // 判断是否评价最后一个联系人
    BOOL isLastEvaluate = YES;
    for(NSInteger index = 0; index < [_recipientArray count]; index++) {
        if(index == indexPath.row) {
            continue;
        }
        
        NSDictionary *recipient = [_recipientArray objectAtIndex:index];
        if([recipient stringForKey:@"score"].length == 0 || [recipient stringForKey:@"access"].length == 0) {
            isLastEvaluate = NO;
            break;
        }
    }
    
    NSDictionary *recipient = [_recipientArray objectAtIndex:indexPath.row];
    
    WorkContactListReplyViewController *viewController = [[WorkContactListReplyViewController alloc] initWithNibName:@"WorkContactListReplyViewController" bundle:nil];
    viewController.workId = self.workId;
    viewController.workType = self.workType;
    viewController.recipientId = [recipient stringForKey:@"staffid"];
    viewController.relationId = [recipient stringForKey:@"id"];
    if([self.workType isEqualToString:@"2"]) {
        viewController.isEnd = [[recipient stringForKey:@"isend"] isEqualToString:@"2"];
        viewController.isLastEvaluate = isLastEvaluate;
    }
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
