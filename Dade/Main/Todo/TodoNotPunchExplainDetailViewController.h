//
//  TodoNotPunchExplainDetailViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-2-5.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  待办内容页（未打卡说明）

#import "BaseViewController.h"

@interface TodoNotPunchExplainDetailViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *todoDetailScrollView;

@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
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
@property (copy, nonatomic) NSString *flowId;

@end
