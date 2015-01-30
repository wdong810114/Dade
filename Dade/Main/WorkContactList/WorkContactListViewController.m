//
//  WorkContactListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "WorkContactListViewController.h"

#import "DraftWorkContactListViewController.h"

@interface WorkContactListViewController ()

@end

@implementation WorkContactListViewController
{
    NSInteger _agencyCount;         // 代办数
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
            cell.textLabel.text = [NSString stringWithFormat:@"代办工作联系单（%i）", (int)_agencyCount];
        }
            break;
        case 2:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"监督工作联系单（%i）", (int)_supervisionCount];
        }
            break;
        case 3:
        {
            cell.textLabel.text = [NSString stringWithFormat:@"工作联系单草稿（%i）", (int)_draftCount];
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
            
        }
            break;
        case 2:
        {
            
        }
            break;
        case 3:
        {
            
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
