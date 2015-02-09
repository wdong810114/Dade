//
//  WorkContactListDetailViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-2-9.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  工作联系单内容页

#import "BaseViewController.h"

@interface WorkContactListDetailViewController : BaseViewController /*<UITableViewDataSource, UITableViewDelegate>*/

@property (weak, nonatomic) IBOutlet UIScrollView *workContactListDetailScrollView;

@property (weak, nonatomic) IBOutlet UILabel *senderLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *operateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *specifiedFinishTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *finishTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *isSMSLabel;
@property (weak, nonatomic) IBOutlet UILabel *daysLabel;
@property (weak, nonatomic) IBOutlet UILabel *isRemindLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIView *recipientsListView;

@property (copy, nonatomic) NSString *workListId;

@end
