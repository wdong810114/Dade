//
//  TodoWorkContactListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-9.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "TodoWorkContactListViewController.h"

#import "WorkContactListDetailViewController.h"

@interface TodoWorkContactListViewController ()

- (void)queryTodoWorkList;
- (void)requestQueryTodoWorkListFinished:(NSString *)jsonString;
- (void)requestQueryTodoWorkListFailed;

@end

@implementation TodoWorkContactListViewController
{
    NSMutableArray *_workListArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.todoWorkContactListTableView.backgroundView = nil;
    self.todoWorkContactListTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.todoWorkContactListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self queryTodoWorkList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"待办工作联系单"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

#pragma mark - Private Methods
- (void)queryTodoWorkList
{
    [self startLoading];
    
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{\"userId\":\"%@\"}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_TODO_WORK_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryTodoWorkListFinished:) didFailSelector:@selector(requestQueryTodoWorkListFailed)];
}

- (void)requestQueryTodoWorkListFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _workListArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self setNavigationBarTitle:[NSString stringWithFormat:@"待办工作联系单(%i)", (int)[_workListArray count]]];
        [self.todoWorkContactListTableView reloadData];
    }
}

- (void)requestQueryTodoWorkListFailed
{
    [self stopLoading];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_workListArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *WorkListCellIdentifier = @"WorkListCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WorkListCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WorkListCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = FONT(14.0);
    }
    
    NSDictionary *workList = [_workListArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [workList stringForKey:@"displayvalue"]];
    
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
    
    NSDictionary *workList = [_workListArray objectAtIndex:indexPath.row];
    
    WorkContactListDetailViewController *viewController = [[WorkContactListDetailViewController alloc] initWithNibName:@"WorkContactListDetailViewController" bundle:nil];
    viewController.workId = [workList stringForKey:@"mailId"];
    viewController.workType = @"1";
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
