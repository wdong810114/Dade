//
//  PersonnelListViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-30.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  人员列表页

#import "BaseViewController.h"

@interface PersonnelListViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIImageView *magnifierImageView;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UITableView *personnelListTableView;
@property (weak, nonatomic) IBOutlet UIButton *allButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *reverseButton;

- (IBAction)allButtonClicked:(UIButton *)button;
- (IBAction)confirmButtonClicked:(UIButton *)button;
- (IBAction)cancelButtonClicked:(UIButton *)button;
- (IBAction)reverseButtonClicked:(UIButton *)button;

@end
