//
//  MailDraftViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  邮件起草页

#import "BaseViewController.h"

@interface MailDraftViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *mailDraftScrollView;

@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *recipientsLabel;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

- (IBAction)addButtonClicked:(UIButton *)button;
- (IBAction)sendButtonClicked:(UIButton *)button;

@end
