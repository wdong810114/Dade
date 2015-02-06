//
//  TodoLeaveApplyDetailViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-2-5.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  待办内容页（请假申请）

#import "BaseViewController.h"

@interface TodoLeaveApplyDetailViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *todoDetailScrollView;

@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *quartersLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaveDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *leaveTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *explainView;
@property (weak, nonatomic) IBOutlet UITextView *explainTextView;
@property (weak, nonatomic) IBOutlet UILabel *explainPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIView *approvalView;

@property (copy, nonatomic) NSString *todoId;
@property (copy, nonatomic) NSString *flowId;

@end
