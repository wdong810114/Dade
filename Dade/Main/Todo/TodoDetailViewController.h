//
//  TodoDetailViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-2-5.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  待办内容页（正常）

#import "BaseViewController.h"

@interface TodoDetailViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *todoDetailScrollView;

@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *quartersLabel;
@property (weak, nonatomic) IBOutlet UILabel *undertakerLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *explainView;
@property (weak, nonatomic) IBOutlet UITextView *explainTextView;
@property (weak, nonatomic) IBOutlet UILabel *explainPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *verifyButton;
@property (weak, nonatomic) IBOutlet UIButton *retreatButton;
@property (weak, nonatomic) IBOutlet UIView *approvalView;

- (IBAction)verifyButtonClicked:(UIButton *)button;
- (IBAction)retreatButtonClicked:(UIButton *)button;

@property (copy, nonatomic) NSString *todoId;

@end
