//
//  WorkContactListReplyViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-2-10.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  工作联系单回复页

#import "BaseViewController.h"

@interface WorkContactListReplyViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *replyScrollView;

@property (weak, nonatomic) IBOutlet UIView *flowListView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeholderLabel;
@property (weak, nonatomic) IBOutlet UIButton *replyButton;

- (IBAction)replyButtonClicked:(UIButton *)button;

@property (copy, nonatomic) NSString *workId;
@property (copy, nonatomic) NSString *workType;     // 1待办，2监督
@property (copy, nonatomic) NSString *recipientId;
@property (copy, nonatomic) NSString *relationId;
@property (assign, nonatomic) BOOL isEnd;           // 是否已完结
@property (assign, nonatomic) BOOL isLastEvaluate;  // 是否评价最后一个联系人

@end
