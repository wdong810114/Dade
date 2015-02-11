//
//  MainViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-21.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "MainViewController.h"

#import "TodoListViewController.h"
#import "NoticeListViewController.h"
#import "MailListViewController.h"
#import "WorkContactListViewController.h"
#import "DraftApprovalDocumentViewController.h"

@interface MainViewController ()

- (void)queryIncomeList;
- (void)requestQueryIncomeListFinished:(NSString *)jsonString;
- (void)requestQueryIncomeListFailed;
- (void)queryNoticeList;
- (void)requestQueryNoticeListFinished:(NSString *)jsonString;
- (void)requestQueryNoticeListFailed;
- (void)queryNewsList;
- (void)requestQueryNewsListFinished:(NSString *)jsonString;
- (void)requestQueryNewsListFailed;

@end

@implementation MainViewController
{
    NSInteger _todoCount;   // 待办数
    NSInteger _noticeCount; // 通知数
    NSInteger _mailCount;   // 邮件数
    
    NSTimeInterval _lastTimeInterval;   // 最近一次刷新时间
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mainTableView.backgroundView = nil;
    self.mainTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(DadeAppDelegate.userInfo) {
        NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
        if(currentTimeInterval - _lastTimeInterval > 10 * 60) {
            // 间隔超过10分钟才刷新
            
            _lastTimeInterval = currentTimeInterval;
            
            [self queryIncomeList];
            [self queryNoticeList];
            [self queryNewsList];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"大德集团"];
}

#pragma mark - Private Methods
- (void)queryIncomeList
{
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{userId:'%@'}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_INCOME_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryIncomeListFinished:) didFailSelector:@selector(requestQueryIncomeListFailed)];
}

- (void)requestQueryIncomeListFinished:(NSString *)jsonString
{
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _todoCount = [jsonArray count];
        
        [self.mainTableView reloadData];
    }
}

- (void)requestQueryIncomeListFailed
{
}

- (void)queryNoticeList
{
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{userId:'%@'}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_NOTICE_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryNoticeListFinished:) didFailSelector:@selector(requestQueryNoticeListFailed)];
}

- (void)requestQueryNoticeListFinished:(NSString *)jsonString
{
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _noticeCount = [jsonArray count];

        [self.mainTableView reloadData];
    }
}

- (void)requestQueryNoticeListFailed
{
}

- (void)queryNewsList
{
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{userId:'%@'}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_NEWS_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryNewsListFinished:) didFailSelector:@selector(requestQueryNewsListFailed)];
}

- (void)requestQueryNewsListFinished:(NSString *)jsonString
{
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _mailCount = [jsonArray count];

        [self.mainTableView reloadData];
    }
}

- (void)requestQueryNewsListFailed
{
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MainCellIdentifier = @"MainCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MainCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MainCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = FONT(16.0);
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.imageView.image = [UIImage imageNamed:@"todo_icon"];
            cell.textLabel.text = [NSString stringWithFormat:@"待办(%i)", (int)_todoCount];
        }
            break;
        case 1:
        {
            cell.imageView.image = [UIImage imageNamed:@"notice_icon"];
            cell.textLabel.text = [NSString stringWithFormat:@"通知(%i)", (int)_noticeCount];
        }
            break;
        case 2:
        {
            cell.imageView.image = [UIImage imageNamed:@"mail_icon"];
            cell.textLabel.text = [NSString stringWithFormat:@"邮件(%i)", (int)_mailCount];
        }
            break;
        case 3:
        {
            cell.imageView.image = [UIImage imageNamed:@"work_contact_list_icon"];
            cell.textLabel.text = @"工作联系单";
        }
            break;
        case 4:
        {
            cell.imageView.image = [UIImage imageNamed:@"draft_approval_document_icon"];
            cell.textLabel.text = @"起草审批文件";
        }
            break;
            
        default:
            break;
    }
    
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
    
    UIViewController *viewController;
    
    switch (indexPath.row) {
        case 0:
        {
            viewController = [[TodoListViewController alloc] initWithNibName:@"TodoListViewController" bundle:nil];
        }
            break;
        case 1:
        {
            viewController = [[NoticeListViewController alloc] initWithNibName:@"NoticeListViewController" bundle:nil];
        }
            break;
        case 2:
        {
            viewController = [[MailListViewController alloc] initWithNibName:@"MailListViewController" bundle:nil];
        }
            break;
        case 3:
        {
            viewController = [[WorkContactListViewController alloc] initWithNibName:@"WorkContactListViewController" bundle:nil];
        }
            break;
        case 4:
        {
            viewController = [[DraftApprovalDocumentViewController alloc] initWithNibName:@"DraftApprovalDocumentViewController" bundle:nil];
        }
            break;
            
        default:
            break;
    }
    
    if(viewController) {
        [self.navigationController pushViewController:viewController animated:YES];
    }
}

@end
