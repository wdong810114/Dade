//
//  DDLoadingView.m
//  Dade
//
//  Created by 王冬冬 on 15-1-21.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "DDLoadingView.h"

#import "Constants.h"

@implementation DDLoadingView
{
    UIView *_bgView;
    UIActivityIndicatorView *_indicatorView;
}

- (void)dealloc
{
    [_indicatorView stopAnimating];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 5.0;
        
        _bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        _bgView.backgroundColor = [UIColor blackColor];
        _bgView.alpha = 0.7;
        [self addSubview:_bgView];
        
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _indicatorView.color = [UIColor whiteColor];
        _indicatorView.center = _bgView.center;
        [self addSubview:_indicatorView];
        
        [_indicatorView startAnimating];
    }
    
    return self;
}

@end
