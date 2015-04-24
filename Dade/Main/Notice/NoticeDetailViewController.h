//
//  NoticeDetailViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-22.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  通知内容页

#import "BaseViewController.h"

@interface NoticeDetailViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *noticeDetailScrollView;

@property (weak, nonatomic) IBOutlet UILabel *markLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectWordsLabel;
@property (weak, nonatomic) IBOutlet UILabel *reportsLabel;
@property (weak, nonatomic) IBOutlet UILabel *handleLabel;
@property (weak, nonatomic) IBOutlet UILabel *handlerLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthLabel;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *copiesLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertDaysLabel;
@property (weak, nonatomic) IBOutlet UIImageView *smsAlertCheckImageView;

@property (weak, nonatomic) IBOutlet UIView *feedbackView;
@property (weak, nonatomic) IBOutlet UILabel *feedbackLabel;
@property (weak, nonatomic) IBOutlet UIImageView *feedbackCheckImageView;
@property (weak, nonatomic) IBOutlet UIView *recipientsView;
@property (weak, nonatomic) IBOutlet UIView *sendButtonView;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;

@property (copy, nonatomic) NSString *noticeId;
@property (copy, nonatomic) NSString *fileTypeId;

- (IBAction)sendButtonClicked:(UIButton *)button;

@end
