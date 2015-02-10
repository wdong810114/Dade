//
//  WorkContactListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "WorkContactListViewController.h"

#import "DraftWorkContactListViewController.h"
#import "TodoWorkContactListViewController.h"
#import "SupervisionWorkContactListViewController.h"
#import "WorkContactListDraftsViewController.h"

@interface WorkContactListViewController ()

- (void)queryTodoWorkList;
- (void)requestQueryTodoWorkListFinished:(ASIHTTPRequest *)request;
- (void)requestQueryTodoWorkListFailed:(ASIHTTPRequest *)request;
- (void)querySupervisionWordList;
- (void)requestQuerySupervisionWordListFinished:(ASIHTTPRequest *)request;
- (void)requestQuerySupervisionWordListFailed:(ASIHTTPRequest *)request;
- (void)querySupervisionWordDraftList;
- (void)requestQuerySupervisionWordDraftListFinished:(ASIHTTPRequest *)request;
- (void)requestQuerySupervisionWordDraftListFailed:(ASIHTTPRequest *)request;

@end

@implementation WorkContactListViewController
{
    NSInteger _todoCount;           // 待办数
    NSInteger _supervisionCount;    // 监督数
    NSInteger _draftCount;          // 草稿数
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.workContactListTableView.backgroundView = nil;
    self.workContactListTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.workContactListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self queryTodoWorkList];
    [self querySupervisionWordList];
    [self querySupervisionWordDraftList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"工作联系单"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

#pragma mark - Private Methods
- (void)queryTodoWorkList
{
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{userId:'%@'}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_TODO_WORK_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryTodoWorkListFinished:) didFailSelector:@selector(requestQueryTodoWorkListFailed:)];
}

- (void)requestQueryTodoWorkListFinished:(ASIHTTPRequest *)request
{
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _todoCount = [jsonArray count];
        
        [self.workContactListTableView reloadData];
    }
    
    [self requestDidFinish:request];
}

- (void)requestQueryTodoWorkListFailed:(ASIHTTPRequest *)request
{
    [self requestDidFail:request];
}

- (void)querySupervisionWordList
{
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{userId:'%@'}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_SUPERVISION_WORD_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQuerySupervisionWordListFinished:) didFailSelector:@selector(requestQuerySupervisionWordListFailed:)];
}

- (void)requestQuerySupervisionWordListFinished:(ASIHTTPRequest *)request
{
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _supervisionCount = [jsonArray count];
        
        [self.workContactListTableView reloadData];
    }
    
    [self requestDidFinish:request];
}

- (void)requestQuerySupervisionWordListFailed:(ASIHTTPRequest *)request
{
    [self requestDidFail:request];
}

- (void)querySupervisionWordDraftList
{
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{userId:'%@'}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_SUPERVISION_WORD_DRAFT_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQuerySupervisionWordDraftListFinished:) didFailSelector:@selector(requestQuerySupervisionWordDraftListFailed:)];
}

- (void)requestQuerySupervisionWordDraftListFinished:(ASIHTTPRequest *)request
{
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _draftCount = [jsonArray count];
        
        [self.workContactListTableView reloadData];
    }
    
    [self requestDidFinish:request];
}

- (void)requestQuerySupervisionWordDraftListFailed:(ASIHTTPRequest *)request
{
    [self requestDidFail:request];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *WorkContactListCellIdentifier = @"WorkContactListCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WorkContactListCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WorkContactListCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"起草工作联系单";
        }
            break;
        case 1:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"待办工作联系单(%i)", (int)_todoCount];
        }
            break;
        case 2:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"监督工作联系单(%i)", (int)_supervisionCount];
        }
            break;
        case 3:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"工作联系单草稿(%i)", (int)_draftCount];
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
            viewController = [[DraftWorkContactListViewController alloc] initWithNibName:@"DraftWorkContactListViewController" bundle:nil];
        }
            break;
        case 1:
        {
            viewController = [[TodoWorkContactListViewController alloc] initWithNibName:@"TodoWorkContactListViewController" bundle:nil];
        }
            break;
        case 2:
        {
            viewController = [[SupervisionWorkContactListViewController alloc] initWithNibName:@"SupervisionWorkContactListViewController" bundle:nil];
        }
            break;
        case 3:
        {
            viewController = [[WorkContactListDraftsViewController alloc] initWithNibName:@"WorkContactListDraftsViewController" bundle:nil];
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
