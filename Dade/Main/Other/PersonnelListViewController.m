//
//  PersonnelListViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-30.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "PersonnelListViewController.h"

@interface PersonnelListViewController ()

- (void)initView;
- (BOOL)checkSelected:(NSDictionary *)personnel;

- (void)queryStaffListByName;
- (void)requestQueryStaffListByNameFinished:(ASIHTTPRequest *)request;
- (void)requestQueryStaffListByNameFailed:(ASIHTTPRequest *)request;

@end

@implementation PersonnelListViewController
{
    NSMutableArray *_personnelArray;
    NSMutableArray *_searchPersonnelArray;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UITextFieldTextDidChangeNotification
                                                  object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _personnelArray = [[NSMutableArray alloc] init];
        _searchPersonnelArray = [[NSMutableArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(textFieldTextDidChange:)
                                                     name:UITextFieldTextDidChangeNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self queryStaffListByName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];

    [self setNavigationBarTitle:@"人员列表"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

- (IBAction)allButtonClicked:(UIButton *)button
{
    // 全选
    
    if([self isRequesting]) {
        return;
    }
    
    for(NSDictionary *personnel in _searchPersonnelArray) {
        if(![self checkSelected:personnel]) {
            [self.selectedIdArray addObject:[personnel stringForKey:@"id"]];
        }
    }
    
    [self.personnelListTableView reloadData];
}

- (IBAction)confirmButtonClicked:(UIButton *)button
{
    // 确定
    
    NSMutableArray *nameArray = [[NSMutableArray alloc] initWithCapacity:[self.selectedIdArray count]];
    for(NSDictionary *personnel in _personnelArray) {
        if([self checkSelected:personnel]) {
            [nameArray addObject:[Util trimString:[personnel stringForKey:@"staffName"]]];
        }
    }
    
    [self.delegate personnelListViewController:self didSelectIds:self.selectedIdArray didSelectNames:nameArray];
    
    [self pop];
}

- (IBAction)cancelButtonClicked:(UIButton *)button
{
    // 取消
    
    [self pop];
}

- (IBAction)reverseButtonClicked:(UIButton *)button
{
    // 反选
    
    if([self isRequesting]) {
        return;
    }
    
    for(NSDictionary *personnel in _searchPersonnelArray) {
        if([self checkSelected:personnel]) {
            [self.selectedIdArray removeObject:[personnel stringForKey:@"id"]];
        } else {
            [self.selectedIdArray addObject:[personnel stringForKey:@"id"]];
        }
    }
    
    [self.personnelListTableView reloadData];
}

- (void)textFieldTextDidChange:(NSNotification *)notification
{
    if([self.searchTextField isFirstResponder]) {
        NSString *keyword = [NSString stringWithString:self.searchTextField.text];
        
        if(keyword.length == 0) {
            _searchPersonnelArray = [[NSMutableArray alloc] initWithArray:_personnelArray];
        } else {
            _searchPersonnelArray = [[NSMutableArray alloc] init];
            for(NSDictionary *personnel in _personnelArray) {
                if([[personnel stringForKey:@"staffName"] rangeOfString:keyword options:NSCaseInsensitiveSearch|NSLiteralSearch].length > 0) {
                    [_searchPersonnelArray addObject:personnel];
                }
            }
        }
        
        [self.personnelListTableView reloadData];
    }
}

#pragma mark - Private Methods
- (void)initView
{
    self.personnelListTableView.backgroundView = nil;
    self.personnelListTableView.backgroundColor = TABLEVIEW_BG_COLOR;
    self.personnelListTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    self.personnelListTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.magnifierImageView.image = [UIImage imageNamed:@"magnifier"];
    
    [self.allButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.allButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.allButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.confirmButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.confirmButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.cancelButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.reverseButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.reverseButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.reverseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

- (BOOL)checkSelected:(NSDictionary *)personnel
{
    BOOL isSelected = NO;
    
    for(NSString *pid in self.selectedIdArray) {
        if([pid isEqualToString:[personnel stringForKey:@"id"]]) {
            isSelected = YES;
            break;
        }
    }
    
    return isSelected;
}

- (void)queryStaffListByName
{
    [self startLoading];
    
//    userName：查询名称
    
    NSString *postString = [NSString stringWithFormat:@"{userName:'%@'}", @""];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:QUERY_STAFF_LIST_BY_NAME_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestQueryStaffListByNameFinished:) didFailSelector:@selector(requestQueryStaffListByNameFailed:)];
}

- (void)requestQueryStaffListByNameFinished:(ASIHTTPRequest *)request
{
    [self stopLoading];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonArray) {
        _personnelArray = [[NSMutableArray alloc] initWithArray:jsonArray];
        _searchPersonnelArray = [[NSMutableArray alloc] initWithArray:jsonArray];

        [self.personnelListTableView reloadData];
    }
    
    [self requestDidFinish:request];
}

- (void)requestQueryStaffListByNameFailed:(ASIHTTPRequest *)request
{
    [self stopLoading];
    
    [self requestDidFail:request];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_searchPersonnelArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *PersonnelListCellIdentifier = @"PersonnelListCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PersonnelListCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PersonnelListCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = FONT(16.0);
        
        UIImageView *selectedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableView.frame.size.width - 15.0 - 18.0, (TABLEVIEW_CELL_HEIGHT - 18.0) / 2, 18.0, 18.0)];
        selectedImageView.backgroundColor = [UIColor clearColor];
        selectedImageView.tag = 101;
        [cell.contentView addSubview:selectedImageView];
    }

    NSDictionary *personnel = [_searchPersonnelArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [personnel stringForKey:@"staffName"]];
    
    UIImageView *selectedImageView = (UIImageView *)[cell.contentView viewWithTag:101];
    if([self checkSelected:personnel]) {
        selectedImageView.image = [UIImage imageNamed:@"row_selected_icon"];
    } else {
        selectedImageView.image = [UIImage imageNamed:@"row_unselected_icon"];
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
    
    NSDictionary *personnel = [_searchPersonnelArray objectAtIndex:indexPath.row];
    
    if([self checkSelected:personnel]) {
        [self.selectedIdArray removeObject:[personnel stringForKey:@"id"]];
    } else {
        [self.selectedIdArray addObject:[personnel stringForKey:@"id"]];
    }
    
    [self.personnelListTableView reloadData];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([self isRequesting]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.searchTextField) {
        [self.searchTextField resignFirstResponder];
    }
    
    return YES;
}

@end
