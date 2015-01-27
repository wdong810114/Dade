//
//  MailDetailViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-26.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "MailDetailViewController.h"

#import "MailReplyViewController.h"

@interface MailDetailViewController ()

- (void)initView;
- (void)refreshView;

@end

@implementation MailDetailViewController
{
    NSString *_subject;     // 主题
    NSString *_sender;      // 发件人
    NSString *_recipients;  // 收件人
    NSString *_time;        // 操作时间
    NSString *_content;     // 内容
}

// 测试---Start
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _subject = @"关于第三季度综合管理检查的邮件";
        _sender = @"王冬冬";
        _recipients = @"葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;";
        _time = @"2015-11-23";
        _content = @"各位领导、同事：\n工作汇报可以按照日程表的格式来提交，在领度企业执行与沟通平台的日程表可以用来填报自己的工作，可以按天，按小时填写汇报工作，填写的内容包含工作摘要、内容、花费时间、对应的任务、上传附件等。";
    }
    
    return self;
    
}
// 测试---End

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"内容详情"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

- (IBAction)replyButtonClicked:(UIButton *)button
{
    // 回复
    
    MailReplyViewController *viewController = [[MailReplyViewController alloc] initWithNibName:@"MailReplyViewController" bundle:nil];
    viewController.recipient = _sender;
    [self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark - Private Methods
- (void)initView
{
    self.mailDetailScrollView.backgroundColor = COLOR(0xf5,0xf5,0xf5);
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.subjectLabel.preferredMaxLayoutWidth = self.subjectLabel.bounds.size.width;
        self.senderLabel.preferredMaxLayoutWidth = self.senderLabel.bounds.size.width;
        self.recipientsLabel.preferredMaxLayoutWidth = self.recipientsLabel.bounds.size.width;
        self.timeLabel.preferredMaxLayoutWidth = self.timeLabel.bounds.size.width;
        self.contentLabel.preferredMaxLayoutWidth = self.contentLabel.bounds.size.width;
    }

    [self.replyButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.replyButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.replyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self refreshView];
}

- (void)refreshView
{
    self.subjectLabel.text = _subject;
    self.senderLabel.text = _sender;
    self.recipientsLabel.text = _recipients;
    self.timeLabel.text = _time;
    self.contentLabel.text = _content;
}

@end
