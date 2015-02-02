//
//  BaseViewController.h
//  Dade
//
//  Created by 王冬冬 on 15-1-21.
//  Copyright (c) 2015年 Spark. All rights reserved.
//
//  基类视图控制器

#import <UIKit/UIKit.h>

#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "Constants.h"
#import "Util.h"
#import "DDLoadingView.h"
#import "AppDelegate.h"

@interface BaseViewController : UIViewController
{
    NSMutableArray *_requestArray;
    DDLoadingView *_loadingView;
}

- (void)setNavigationBar;
- (void)setNavigationBarTitle:(NSString *)title;
- (void)setLeftBarButtonItem:(SEL)action image:(NSString *)image highlightedImage:(NSString *)highlightedImage;
- (void)setRightBarButtonItem:(SEL)action image:(NSString *)image highlightedImage:(NSString *)highlightedImage;
- (void)setRightBarButtonItem:(SEL)action title:(NSString *)title;

- (void)pop;

@end

@interface BaseViewController (Network)

- (ASIFormDataRequest *)requestWithRelativeURL:(NSString *)relativeURL;
- (void)startRequest:(ASIFormDataRequest *)request didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector;
- (void)requestDidFinish:(ASIHTTPRequest *)request;
- (void)requestDidFail:(ASIHTTPRequest *)request;

@end

@interface BaseViewController (Loading)

- (BOOL)isLoading;
- (void)addLoadingView;
- (void)addLoadingView:(CGRect)frame;
- (void)removeLoadingView;

@end

@interface BaseViewController (Alert)

- (void)showAlert:(NSString *)title;

@end
