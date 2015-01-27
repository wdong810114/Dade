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

@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *departmentLabel;
@property (weak, nonatomic) IBOutlet UILabel *quartersLabel;
@property (weak, nonatomic) IBOutlet UILabel *undertakerLabel;
@property (weak, nonatomic) IBOutlet UILabel *recipientsLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@end
