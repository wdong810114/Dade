//
//  TodoDetailViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-2-5.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  待办内容页

#import "BaseViewController.h"

@interface TodoDetailViewController : BaseViewController

@property (weak, nonatomic) IBOutlet UIScrollView *todoDetailScrollView;

@property (copy, nonatomic) NSString *todoId;

@end
