//
//  WorkContactListDraftsViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-30.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "WorkContactListDraftsViewController.h"

#import "DraftWorkContactListViewController.h"

@interface WorkContactListDraftsViewController ()

- (void)showDeleteAlert:(NSString *)title;
- (void)deleteDraft;

@end

@implementation WorkContactListDraftsViewController
{
    NSMutableArray *_draftArray;
    
    NSIndexPath *_willDeleteIndexPath;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _draftArray = [[NSMutableArray alloc] initWithObjects:@"草稿1", @"草稿2", @"草稿3", @"草稿4", @"草稿5", @"草稿6", @"草稿7", @"草稿8", nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.workContactListDraftsTableView.backgroundView = nil;
    self.workContactListDraftsTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.workContactListDraftsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"工作联系单草稿"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

#pragma mark - Private Methods
- (void)showDeleteAlert:(NSString *)title
{
    if(IOS_VERSION_8_OR_ABOVE) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ALERT_BUTTON_TITLE_CANCEL
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction *action) {
                                                             }];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:ALERT_BUTTON_TITLE_CONFIRM
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  [self deleteDraft];
                                                              }];
        [alertController addAction:cancelAction];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:NULL];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:ALERT_BUTTON_TITLE_CANCEL
                                                  otherButtonTitles:ALERT_BUTTON_TITLE_CONFIRM, nil];
        [alertView show];
    }
}

- (void)deleteDraft
{
    if(_willDeleteIndexPath) {
        [_draftArray removeObjectAtIndex:_willDeleteIndexPath.row];
        
        [self.workContactListDraftsTableView beginUpdates];
        [self.workContactListDraftsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_willDeleteIndexPath] withRowAnimation:UITableViewRowAnimationTop];
        [self.workContactListDraftsTableView endUpdates];
        
        _willDeleteIndexPath = nil;
    }
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.cancelButtonIndex != buttonIndex) {
        [self deleteDraft];
    }
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_draftArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *WorkContactListDraftsCellIdentifier = @"WorkContactListDraftsCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:WorkContactListDraftsCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:WorkContactListDraftsCellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = FONT(14.0);
    }
    
    cell.textLabel.text = [_draftArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(UITableViewCellEditingStyleDelete == editingStyle) {
        _willDeleteIndexPath = indexPath;
        
        [self showDeleteAlert:@"确定要删除该条草稿吗？"];
    }
}

#pragma mark - UITableViewDelegate Methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TABLEVIEW_CELL_HEIGHT;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    DraftWorkContactListViewController *viewController = [[DraftWorkContactListViewController alloc] initWithNibName:@"DraftWorkContactListViewController" bundle:nil];
    viewController.entranceType = ENTRANCE_TYPE_EDIT;
    [self.navigationController pushViewController:viewController animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

@end
