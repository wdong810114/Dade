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
- (void)requestQueryNoticeListFinished:(NSString *)jsonString;
- (void)requestQueryNoticeListFailed;

@end

@implementation NoticeListViewController
{
    NSMutableArray *_noticeArray;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DDNoticeListRefreshNotification
                                                  object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshView:)
                                                     name:DDNoticeListRefreshNotification
                                                   object:nil];
    }
    
    return self;
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

- (void)refreshView:(NSNotification *)notification
{
    [self queryNoticeList];
}

#pragma mark - Private Methods
- (void)queryNoticeList
{
    [self startLoading];
    
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{\"userId\":\"%@\"}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_NOTICE_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryNoticeListFinished:) didFailSelector:@selector(requestQueryNoticeListFailed)];
}

- (void)requestQueryNoticeListFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _noticeArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self setNavigationBarTitle:[NSString stringWithFormat:@"通知(%i)", (int)_noticeArray.count]];
        [self.noticeListTableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DDMainRefreshNotification object:@{@"type":@2, @"count":[NSNumber numberWithInteger:_noticeArray.count]}];
    }
}

- (void)requestQueryNoticeListFailed
{
    [self stopLoading];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _noticeArray.count;
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
