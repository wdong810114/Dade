//
//  DraftApprovalDocumentViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "DraftApprovalDocumentViewController.h"

#import "MailDraftViewController.h"
#import "LeaveApplyViewController.h"
#import "NotPunchExplainViewController.h"
#import "NoticeDraftViewController.h"

@interface DraftApprovalDocumentViewController ()

@end

@implementation DraftApprovalDocumentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.draftApprovalDocumentTableView.backgroundView = nil;
    self.draftApprovalDocumentTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.draftApprovalDocumentTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"起草审批文件"];
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
        cell.textLabel.font = FONT(16.0);
    }
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"邮件起草";
        }
            break;
        case 1:
        {
            cell.textLabel.text = @"请假申请";
        }
            break;
        case 2:
        {
            cell.textLabel.text = @"未打卡说明";
        }
            break;
        case 3:
        {
            cell.textLabel.text = @"通知起草";
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
            viewController = [[MailDraftViewController alloc] initWithNibName:@"MailDraftViewController" bundle:nil];
        }
            break;
        case 1:
        {
            viewController = [[LeaveApplyViewController alloc] initWithNibName:@"LeaveApplyViewController" bundle:nil];
        }
            break;
        case 2:
        {
            viewController = [[NotPunchExplainViewController alloc] initWithNibName:@"NotPunchExplainViewController" bundle:nil];
        }
            break;
        case 3:
        {
            viewController = [[NoticeDraftViewController alloc] initWithNibName:@"NoticeDraftViewController" bundle:nil];
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
