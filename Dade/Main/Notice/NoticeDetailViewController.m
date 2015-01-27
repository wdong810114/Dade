//
//  NoticeDetailViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-22.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "NoticeDetailViewController.h"

@interface NoticeDetailViewController ()

- (void)initView;
- (void)refreshView;

@end

@implementation NoticeDetailViewController
{
    NSString *_subject;     // 主题
    NSString *_department;  // 部门
    NSString *_quarters;    // 岗位
    NSString *_undertaker;  // 承办
    NSString *_recipients;  // 接收人员
    NSString *_content;     // 内容
}

// 测试---Start
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _subject = @"关于第三季度综合管理检查的通知";
        _department = @"房地产综合管理部";
        _quarters = @"房地产部门主管";
        _undertaker = @"卢帅";
        _recipients = @"葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;葛立群;崔明东;";
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

#pragma mark - Private Methods
- (void)initView
{
    self.noticeDetailScrollView.backgroundColor = COLOR(0xf5,0xf5,0xf5);
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.subjectLabel.preferredMaxLayoutWidth = self.subjectLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
        self.quartersLabel.preferredMaxLayoutWidth = self.quartersLabel.bounds.size.width;
        self.undertakerLabel.preferredMaxLayoutWidth = self.undertakerLabel.bounds.size.width;
        self.recipientsLabel.preferredMaxLayoutWidth = self.recipientsLabel.bounds.size.width;
        self.contentLabel.preferredMaxLayoutWidth = self.contentLabel.bounds.size.width;
    }
    
    [self refreshView];
}

- (void)refreshView
{
    self.subjectLabel.text = _subject;
    self.departmentLabel.text = _department;
    self.quartersLabel.text = _quarters;
    self.undertakerLabel.text = _undertaker;
    self.recipientsLabel.text = _recipients;
    self.contentLabel.text = _content;
}

@end
