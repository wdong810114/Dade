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

@property (weak, nonatomic) IBOutlet UILabel *recipientsLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIView *departmentView;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UIImageView *departmentArrowImageView;
@property (weak, nonatomic) IBOutlet UIView *subjectView;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UIImageView *checkImageView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *contentPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

- (IBAction)addButtonClicked:(UIButton *)button;
- (IBAction)sendButtonClicked:(UIButton *)button;

@end
