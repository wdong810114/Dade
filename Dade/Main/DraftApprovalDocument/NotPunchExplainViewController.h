//
//  NotPunchExplainViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  未打卡说明页

#import "BaseViewController.h"

@interface NotPunchExplainViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *notPunchExplainScrollView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UIView *numberView;
@property (weak, nonatomic) IBOutlet UITextField *numberTextField;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UIView *notPunchView;
@property (weak, nonatomic) IBOutlet UITextView *notPunchTextView;
@property (weak, nonatomic) IBOutlet UILabel *notPunchPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIView *explainView;
@property (weak, nonatomic) IBOutlet UITextView *explainTextView;
@property (weak, nonatomic) IBOutlet UILabel *explainPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIView *approvalView;

- (IBAction)reportButtonClicked:(UIButton *)button;

@end
