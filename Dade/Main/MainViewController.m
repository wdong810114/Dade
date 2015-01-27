//
//  MainViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-21.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "MainViewController.h"

#import "NoticeListViewController.h"
#import "MailListViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
{
    NSInteger _agencyCount; // 代办数
    NSInteger _noticeCount; // 通知数
    NSInteger _mailCount;   // 邮件数
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mainTableView.backgroundView = nil;
    self.mainTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.mainTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.imageView.image = [UIImage imageNamed:@"agency_icon"];
            cell.textLabel.text = [NSString stringWithFormat:@"代办（%i）", (int)_agencyCount];
        }
            break;
        case 1:
        {
            cell.imageView.image = [UIImage imageNamed:@"notice_icon"];
            cell.textLabel.text = [NSString stringWithFormat:@"通知（%i）", (int)_noticeCount];
        }
            break;
        case 2:
        {
            cell.imageView.image = [UIImage imageNamed:@"mail_icon"];
            cell.textLabel.text = [NSString stringWithFormat:@"邮件（%i）", (int)_mailCount];
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

        }
            break;
        case 4:
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
