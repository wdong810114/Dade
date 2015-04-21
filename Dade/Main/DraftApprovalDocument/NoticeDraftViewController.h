//
//  NoticeDraftViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  通知起草页

#import "BaseViewController.h"

#import "PersonnelListViewController.h"

@interface NoticeDraftViewController : BaseViewController <UIPickerViewDataSource, UIPickerViewDelegate, PersonnelListViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *noticeDraftScrollView;

@property (weak, nonatomic) IBOutlet UIView *markView;
@property (weak, nonatomic) IBOutlet UITextField *markYearTextField;
@property (weak, nonatomic) IBOutlet UITextField *markNumberTextField;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *contentPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIView *subjectView;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UIImageView *feedbackCheckImageView;
@property (weak, nonatomic) IBOutlet UIView *subjectWordsView;
@property (weak, nonatomic) IBOutlet UITextField *subjectWordsTextField;
@property (weak, nonatomic) IBOutlet UILabel *reportsLabel;
@property (weak, nonatomic) IBOutlet UIButton *reportsAddButton;
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UILabel *handlerLabel;
@property (weak, nonatomic) IBOutlet UIView *departmentView;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *departmentArrowImageView;
@property (weak, nonatomic) IBOutlet UIView *dateView;
@property (weak, nonatomic) IBOutlet UITextField *yearTextField;
@property (weak, nonatomic) IBOutlet UITextField *monthTextField;
@property (weak, nonatomic) IBOutlet UITextField *dayTextField;
@property (weak, nonatomic) IBOutlet UITextField *copiesTextField;
@property (weak, nonatomic) IBOutlet UILabel *recipientsLabel;
@property (weak, nonatomic) IBOutlet UIButton *recipientsAddButton;
@property (weak, nonatomic) IBOutlet UIView *smsAlertView;
@property (weak, nonatomic) IBOutlet UITextField *smsAlertDaysTextField;
@property (weak, nonatomic) IBOutlet UIView *smsAlertCheckView;
@property (weak, nonatomic) IBOutlet UIImageView *smsAlertCheckImageView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

- (IBAction)reportsAddButtonClicked:(UIButton *)button;
- (IBAction)recipientsAddButtonClicked:(UIButton *)button;
- (IBAction)sendButtonClicked:(UIButton *)button;

@end
