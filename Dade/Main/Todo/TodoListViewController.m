//
//  TodoListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-30.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "TodoListViewController.h"

@interface TodoListViewController ()

- (void)queryIncomeList;
- (void)requestQueryIncomeListFinished:(ASIHTTPRequest *)request;
- (void)requestQueryIncomeListFailed:(ASIHTTPRequest *)request;

@end

@implementation TodoListViewController
{
    NSMutableArray *_todoArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.todoListTableView.backgroundView = nil;
    self.todoListTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.todoListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self queryIncomeList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"待办"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

#pragma mark - Private Methods
- (void)queryIncomeList
{
    [self addLoadingView];
    
    NSString *postString = [NSString stringWithFormat:@"{userId:'%@'}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_INCOME_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryIncomeListFinished:) didFailSelector:@selector(requestQueryIncomeListFailed:)];
}

- (void)requestQueryIncomeListFinished:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _todoArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self.todoListTableView reloadData];
    }
    
    [self requestDidFinish:request];
}

- (void)requestQueryIncomeListFailed:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    [self requestDidFail:request];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_todoArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *TodoListCellIdentifier = @"TodoListCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:TodoListCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TodoListCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = FONT(14.0);
    }
    
    NSDictionary *income = [_todoArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [income stringForKey:@"displayvalue"];
    
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
    
//    NSDictionary *income = [_todoArray objectAtIndex:indexPath.row];
}

@end
