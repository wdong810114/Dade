//
//  MailListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-26.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "MailListViewController.h"

#import "MailDetailViewController.h"

@interface MailListViewController ()

- (void)queryNewsList;
- (void)requestQueryNewsListFinished:(NSString *)jsonString;
- (void)requestQueryNewsListFailed;

@end

@implementation MailListViewController
{
    NSMutableArray *_mailArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mailListTableView.backgroundView = nil;
    self.mailListTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.mailListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self queryNewsList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"邮件"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

#pragma mark - Private Methods
- (void)queryNewsList
{
    [self startLoading];
    
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{\"userId\":\"%@\"}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_NEWS_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryNewsListFinished:) didFailSelector:@selector(requestQueryNewsListFailed)];
}

- (void)requestQueryNewsListFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _mailArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self setNavigationBarTitle:[NSString stringWithFormat:@"邮件(%i)", (int)_mailArray.count]];
        [self.mailListTableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DDMainRefreshNotification object:@{@"type":@3, @"count":[NSNumber numberWithInteger:_mailArray.count]}];
    }
}

- (void)requestQueryNewsListFailed
{
    [self stopLoading];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mailArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MailListCellIdentifier = @"MailListCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MailListCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:MailListCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = FONT(14.0);
    }
    
    NSDictionary *mail = [_mailArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", [Util trimString:[mail stringForKey:@"staffName"]], [mail stringForKey:@"displayvalue"]];
    
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
    
    NSDictionary *mail = [_mailArray objectAtIndex:indexPath.row];
    
    MailDetailViewController *viewController = [[MailDetailViewController alloc] initWithNibName:@"MailDetailViewController" bundle:nil];
    viewController.mailId = [mail stringForKey:@"id"];
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
