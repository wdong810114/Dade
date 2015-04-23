//
//  SupervisionWorkContactListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-9.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "SupervisionWorkContactListViewController.h"

#import "WorkContactListDetailViewController.h"

@interface SupervisionWorkContactListViewController ()

- (void)querySupervisionWordList;
- (void)requestQuerySupervisionWordListFinished:(NSString *)jsonString;
- (void)requestQuerySupervisionWordListFailed;

@end

@implementation SupervisionWorkContactListViewController
{
    NSMutableArray *_workListArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.supervisionWorkContactListTableView.backgroundView = nil;
    self.supervisionWorkContactListTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.supervisionWorkContactListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self querySupervisionWordList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"监督工作联系单"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

#pragma mark - Private Methods
- (void)querySupervisionWordList
{
    [self startLoading];
    
//    userId ：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{\"userId\":\"%@\"}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_SUPERVISION_WORD_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQuerySupervisionWordListFinished:) didFailSelector:@selector(requestQuerySupervisionWordListFailed)];
}

- (void)requestQuerySupervisionWordListFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _workListArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self setNavigationBarTitle:[NSString stringWithFormat:@"监督工作联系单(%i)", (int)_workListArray.count]];
        [self.supervisionWorkContactListTableView reloadData];
    }
}

- (void)requestQuerySupervisionWordListFailed
{
    [self stopLoading];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _workListArray.count;
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
    viewController.workType = @"2";
    [self.navigationController pushViewController:viewController animated:YES];
}

@end
