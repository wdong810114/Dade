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

@end

@implementation PersonnelListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
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
}

- (IBAction)confirmButtonClicked:(UIButton *)button
{
    // 确定
}

- (IBAction)cancelButtonClicked:(UIButton *)button
{
    // 取消
}

- (IBAction)reverseButtonClicked:(UIButton *)button
{
    // 反选
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

#pragma mark - UITableViewDataSource Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *PersonnelListCellIdentifier = @"PersonnelListCellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PersonnelListCellIdentifier];
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PersonnelListCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = FONT(16.0);
    }

    cell.textLabel.text = @"王冬冬";
    
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
}

@end
