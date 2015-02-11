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

- (void)querySupervisionWordDraftList;
- (void)requestQuerySupervisionWordDraftListFinished:(NSString *)jsonString;
- (void)requestQuerySupervisionWordDraftListFailed;
- (void)deleteTodoWord;
- (void)requestDeleteTodoWordFinished:(NSString *)jsonString;
- (void)requestDeleteTodoWordFailed;

@end

@implementation WorkContactListDraftsViewController
{
    NSMutableArray *_draftArray;
    
    NSIndexPath *_willDeleteIndexPath;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.workContactListDraftsTableView.backgroundView = nil;
    self.workContactListDraftsTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.workContactListDraftsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self querySupervisionWordDraftList];
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
                                                                  [self deleteTodoWord];
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

- (void)querySupervisionWordDraftList
{
    [self startLoading];
    
//    userId：用户Id
    
    NSString *postString = [NSString stringWithFormat:@"{userId:'%@'}", DadeAppDelegate.userInfo.staffId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_SUPERVISION_WORD_DRAFT_LIST_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQuerySupervisionWordDraftListFinished:) didFailSelector:@selector(requestQuerySupervisionWordDraftListFailed)];
}

- (void)requestQuerySupervisionWordDraftListFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _draftArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        
        [self setNavigationBarTitle:[NSString stringWithFormat:@"工作联系单草稿(%i)", (int)[_draftArray count]]];
        [self.workContactListDraftsTableView reloadData];
    }
}

- (void)requestQuerySupervisionWordDraftListFailed
{
    [self stopLoading];
}

- (void)deleteTodoWord
{
    if(_willDeleteIndexPath) {
        [self startLoading];
        
//    wordId：联系单主键
        
        NSString *workId = [(NSDictionary *)[_draftArray objectAtIndex:_willDeleteIndexPath.row] stringForKey:@"mailId"];
        
        NSString *postString = [NSString stringWithFormat:@"{wordId:'%@'}", workId];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:DELETE_TODO_WORD_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestDeleteTodoWordFinished:) didFailSelector:@selector(requestDeleteTodoWordFailed)];
    }
}

- (void)requestDeleteTodoWordFinished:(NSString *)jsonString
{
    [self stopLoading];
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        NSString *ajaxToken = [jsonDict stringForKey:@"ajax_token"];
        if([ajaxToken integerValue] == 0) {
            [_draftArray removeObjectAtIndex:_willDeleteIndexPath.row];
            
            [self.workContactListDraftsTableView beginUpdates];
            [self.workContactListDraftsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:_willDeleteIndexPath] withRowAnimation:UITableViewRowAnimationTop];
            [self.workContactListDraftsTableView endUpdates];
            
            _willDeleteIndexPath = nil;
            
            [self setNavigationBarTitle:[NSString stringWithFormat:@"工作联系单草稿(%i)", (int)[_draftArray count]]];
        }
    }
}

- (void)requestDeleteTodoWordFailed
{
    [self stopLoading];
}

#pragma mark - UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView.cancelButtonIndex != buttonIndex) {
        [self deleteTodoWord];
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

    NSDictionary *draft = [_draftArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [draft stringForKey:@"displayvalue"]];
    
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

    NSDictionary *draft = [_draftArray objectAtIndex:indexPath.row];
    
    DraftWorkContactListViewController *viewController = [[DraftWorkContactListViewController alloc] initWithNibName:@"DraftWorkContactListViewController" bundle:nil];
    viewController.workId = [draft stringForKey:@"mailId"];
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
