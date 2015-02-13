//
//  WorkContactListEvaluateViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-2-10.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  工作联系单评价页

#import "BaseViewController.h"

@interface WorkContactListEvaluateViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *evaluateScrollView;

@property (weak, nonatomic) IBOutlet UIView *scoreView;
@property (weak, nonatomic) IBOutlet UITextField *scoreTextField;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *evaluateButton;

- (IBAction)evaluateButtonClicked:(UIButton *)button;

@property (copy, nonatomic) NSString *workId;
@property (copy, nonatomic) NSString *relationId;
@property (assign, nonatomic) BOOL isLastEvaluate;  // 是否评价最后一个联系人
@property (copy, nonatomic) NSString *evaluateScore;    // 评价分数
@property (copy, nonatomic) NSString *evaluateContent;  // 评价内容

@end
