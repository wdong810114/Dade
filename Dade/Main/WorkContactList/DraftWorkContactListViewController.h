//
//  DraftWorkContactListViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-30.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  起草工作联系单页/草稿详情页

#import "BaseViewController.h"

#import "PersonnelListViewController.h"

@interface DraftWorkContactListViewController : BaseViewController <PersonnelListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *draftWorkContactListScrollView;

@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *recipientsLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UITextField *dateTextField;
@property (weak, nonatomic) IBOutlet UIView *smsAlertView;
@property (weak, nonatomic) IBOutlet UITextField *smsAlertTextField;
@property (weak, nonatomic) IBOutlet UIView *subjectView;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

- (IBAction)sendButtonClicked:(UIButton *)button;
- (IBAction)addButtonClicked:(UIButton *)button;

@property (copy, nonatomic) NSString *workId;

@end
