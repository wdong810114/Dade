//
//  NoticeListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-22.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "NoticeListViewController.h"

#import "NoticeDetailViewController.h"

@interface NoticeListViewController ()

- (void)queryNoticeList;
- (void)requestQueryNoticeListFinished:(ASIHTTPRequest *)request;
- (void)requestQueryNoticeListFailed:(ASIHTTPRequest *)request;

@end

@implementation NoticeListViewController
{
    NSMutableArray *_noticeArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.noticeListTableView.backgroundView = nil;
    self.noticeListTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.noticeListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self queryNoticeList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"通知"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

#pragma mark - Private Methods
- (void)queryNoticeList
{
    [self addLoadingView];
    
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{userId:'%@'}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_NOTICE_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryNoticeListFinished:) didFailSelector:@selector(requestQueryNoticeListFailed:)];
}

- (void)requestQueryNoticeListFinished:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _noticeArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self setNavigationBarTitle:[NSString stringWithFormat:@"通知(%i)", [_noticeArray count]]];
        [self.noticeListTableView reloadData];
    }
    
    [self requestDidFinish:request];
}

- (void)requestQueryNoticeListFailed:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    [self requestDidFail:request];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_noticeArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *NoticeListCellIdentifier = @"NoticeListCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NoticeListCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NoticeListCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = FONT(14.0);
    }
    
    NSDictionary *notice = [_noticeArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"通知:%@", [notice stringForKey:@"displayvalue"]];
    
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
    
    NSDictionary *notice = [_noticeArray objectAtIndex:indexPath.row];
    
    NoticeDetailViewController *viewController = [[NoticeDetailViewController alloc] initWithNibName:@"NoticeDetailViewController" bundle:nil];
    viewController.noticeId = [notice stringForKey:@"id"];
    viewController.fileTypeId = [notice stringForKey:@"filetypeid"];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
