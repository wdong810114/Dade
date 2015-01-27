//
//  MailDetailViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-26.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  邮件内容页

#import "BaseViewController.h"

@interface MailDetailViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *mailDetailScrollView;

@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *recipientsLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;

- (IBAction)replyButtonClicked:(UIButton *)button;

@end
