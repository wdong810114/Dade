//
//  TodoNotPunchExplainDetailViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-5.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "TodoNotPunchExplainDetailViewController.h"

@interface TodoNotPunchExplainDetailViewController ()

@end

@implementation TodoNotPunchExplainDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
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

@end
