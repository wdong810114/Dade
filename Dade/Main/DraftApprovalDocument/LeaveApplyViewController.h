//
//  LeaveApplyViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  请假申请页

#import "BaseViewController.h"

@interface LeaveApplyViewController : BaseViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *leaveApplyScrollView;

@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UIView *leaveDateView;
@property (weak, nonatomic) IBOutlet UITextField *leaveDateTextField;
@property (weak, nonatomic) IBOutlet UIView *leaveTypeView;
@property (weak, nonatomic) IBOutlet UILabel *leaveTypeLabel;
@property (weak, nonatomic) IBOutlet UIView *leaveDaysView;
@property (weak, nonatomic) IBOutlet UITextField *leaveDaysTextField;
@property (weak, nonatomic) IBOutlet UIImageView *arrowImageView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *contentPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIView *explainView;
@property (weak, nonatomic) IBOutlet UITextView *explainTextView;
@property (weak, nonatomic) IBOutlet UILabel *explainPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIView *approvalView;

- (IBAction)reportButtonClicked:(UIButton *)button;

@end
