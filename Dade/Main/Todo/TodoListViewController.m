//
//  TodoListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-30.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "TodoListViewController.h"

#import "TodoDetailViewController.h"
#import "TodoLeaveApplyDetailViewController.h"
#import "TodoNotPunchExplainDetailViewController.h"

@interface TodoListViewController ()

- (void)queryIncomeList;
- (void)requestQueryIncomeListFinished:(NSString *)jsonString;
- (void)requestQueryIncomeListFailed;

@end

@implementation TodoListViewController
{
    NSMutableArray *_todoArray;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:DDTodoListRefreshNotification
                                                  object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(refreshView:)
                                                     name:DDTodoListRefreshNotification
                                                   object:nil];
    }
    
    return self;
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

- (void)refreshView:(NSNotification *)notification
{
    [self queryIncomeList];
}

#pragma mark - Private Methods
- (void)queryIncomeList
{
    [self startLoading];
    
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{\"userId\":\"%@\"}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_INCOME_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryIncomeListFinished:) didFailSelector:@selector(requestQueryIncomeListFailed)];
}

- (void)requestQueryIncomeListFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _todoArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self setNavigationBarTitle:[NSString stringWithFormat:@"待办(%i)", (int)_todoArray.count]];
        [self.todoListTableView reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DDMainRefreshNotification object:@{@"type":@1, @"count":[NSNumber numberWithInteger:_todoArray.count]}];
    }
}

- (void)requestQueryIncomeListFailed
{
    [self stopLoading];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _todoArray.count;
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
    cell.textLabel.text = [NSString stringWithFormat:@"%@:%@", [income stringForKey:@"filetype"], [income stringForKey:@"displayvalue"]];
    
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
    
    NSDictionary *income = [_todoArray objectAtIndex:indexPath.row];
    NSString *fileTypeId = [income stringForKey:@"filetypeid"];
    NSString *flowId = [income stringForKey:@"flowid"];
    NSString *todoId = [income stringForKey:@"id"];
    
    if([fileTypeId isEqualToString:@"113"]) {
        // 请假申请
        
        TodoLeaveApplyDetailViewController *viewController = [[TodoLeaveApplyDetailViewController alloc] initWithNibName:@"TodoLeaveApplyDetailViewController" bundle:nil];
        viewController.todoId = todoId;
        viewController.flowId = flowId;
        [self.navigationController pushViewController:viewController animated:YES];
    } else if([fileTypeId isEqualToString:@"114"]) {
        // 未打卡说明
        
        TodoNotPunchExplainDetailViewController *viewController = [[TodoNotPunchExplainDetailViewController alloc] initWithNibName:@"TodoNotPunchExplainDetailViewController" bundle:nil];
        viewController.todoId = todoId;
        viewController.flowId = flowId;
        [self.navigationController pushViewController:viewController animated:YES];
    } else {
        // 正常
        
        TodoDetailViewController *viewController = [[TodoDetailViewController alloc] initWithNibName:@"TodoDetailViewController" bundle:nil];
        viewController.todoId = todoId;
        viewController.fileTypeId = fileTypeId;
        viewController.flowId = flowId;
        [self.navigationController pushViewController:viewController animated:YES];
    }

}

@end
