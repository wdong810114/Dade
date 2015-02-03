//
//  MailReplyViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-26.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  邮件回复页

#import "BaseViewController.h"

@interface MailReplyViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UITextField *subjectTextField;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;

- (IBAction)replyButtonClicked:(UIButton *)button;

@property (copy, nonatomic) NSString *recipient;    // 收件人
@property (copy, nonatomic) NSString *mailId;

@end
