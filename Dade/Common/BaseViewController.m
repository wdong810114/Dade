//
//  BaseViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-21.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#pragma clang diagnostic ignored "-Warc-performSelector-leaks"

#import "BaseViewController.h"

@interface BaseViewController ()

@end

@implementation BaseViewController

- (void)dealloc
{
    for(ASIHTTPRequest *request in _requestArray) {
        [request clearDelegatesAndCancel];
    }
    [_requestArray removeAllObjects];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        _requestArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setNavigationBar];

    if(IOS_VERSION_7_OR_ABOVE) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(IOS_VERSION_7_OR_ABOVE) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    } else {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    UINavigationBar *navigationBar = self.navigationController.navigationBar;
    if(IOS_VERSION_7_OR_ABOVE) {
        navigationBar.translucent = NO;
        navigationBar.barTintColor = NAVIGATION_BAR_COLOR;
        [navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    } else {
        [navigationBar setBackgroundImage:[Util imageWithColor:NAVIGATION_BAR_COLOR] forBarMetrics:UIBarMetricsDefault];
    }
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.navigationItem.hidesBackButton = YES;
    }
    self.navigationItem.titleView = nil;
}

- (void)setNavigationBarTitle:(NSString *)title
{
    self.navigationItem.title = title;
}

- (void)setLeftBarButtonItem:(SEL)action image:(NSString *)image highlightedImage:(NSString *)highlightedImage
{
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0.0, 0.0, 37.0, 35.0);
    if(IOS_VERSION_7_OR_ABOVE) {
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -24.0, 0.0, 0.0);
    } else {
        leftButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, -4.0, 0.0, 0.0);
    }
    [leftButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    [leftButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    self.navigationItem.leftBarButtonItem = leftButtonItem;
}

- (void)setRightBarButtonItem:(SEL)action image:(NSString *)image highlightedImage:(NSString *)highlightedImage
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0.0, 0.0, 37.0, 35.0);
    if(IOS_VERSION_7_OR_ABOVE) {
        rightButton.imageEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -20.0);
    }
    [rightButton setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)setRightBarButtonItem:(SEL)action title:(NSString *)title
{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake(0.0, 0.0, 37.0, 35.0);
    if(IOS_VERSION_7_OR_ABOVE) {
        rightButton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, -20.0);
    }
    rightButton.titleLabel.font = FONT(14.0);
    [rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:COLOR(0xff,0x75,0x22) forState:UIControlStateHighlighted];
    [rightButton setTitle:title forState:UIControlStateNormal];
    [rightButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithCustomView:rightButton];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
}

- (void)pop
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end

@implementation BaseViewController (Network)

- (ASIFormDataRequest *)requestWithRelativeURL:(NSString *)relativeURL
{
    NSString *url = [NSString stringWithFormat:relativeURL, BASE_REQUEST_URL];
    NSURL *requstURL = [NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc] initWithURL:requstURL];
    request.requestMethod = @"POST";
    
    return request;
}

- (void)startRequest:(ASIFormDataRequest *)request didFinishSelector:(SEL)didFinishSelector didFailSelector:(SEL)didFailSelector
{
    [_requestArray addObject:request];
    
    [DadeAppDelegate.engine appendHttpRequest:request
                                     delegate:self
                            didFinishSelector:didFinishSelector
                              didFailSelector:didFailSelector];
}

- (void)requestDidFinish:(ASIHTTPRequest *)request
{
    [request clearDelegatesAndCancel];
    [_requestArray removeObject:request];
}

- (void)requestDidFail:(ASIHTTPRequest *)request
{
    [self showAlert:@"网络连接不可用，请检查你的网络连接"];
    
    [request clearDelegatesAndCancel];
    [_requestArray removeObject:request];
}

- (BOOL)isRequesting
{
    return [_requestArray count] > 0;
}

- (BOOL)isSingleRequesting
{
    return [_requestArray count] == 1;
}

@end

@implementation BaseViewController (Alert)

- (void)showAlert:(NSString *)title
{
    if(IOS_VERSION_8_OR_ABOVE) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:ALERT_BUTTON_TITLE_CONFIRM
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                              }];
        [alertController addAction:confirmAction];
        
        [self presentViewController:alertController animated:YES completion:NULL];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:ALERT_BUTTON_TITLE_CONFIRM, nil];
        [alertView show];
    }
}

@end

@implementation BaseViewController (Loading)

- (BOOL)isLoading
{
    return (_loadingView == nil) ? NO : YES;
}

- (void)startLoading
{
    CGFloat sizeWidth = 100.0;
    CGFloat sizeHeight = 100.0;
    CGFloat originX = (DEVICE_WIDTH - sizeWidth) / 2;
    CGFloat originY = (DEVICE_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - sizeHeight) / 2;
    
    [self startLoading:CGRectMake(originX, originY, sizeWidth, sizeHeight)];
}

- (void)startLoading:(CGRect)frame
{
    [self stopLoading];
    
    _loadingView = [[DDLoadingView alloc] initWithFrame:frame];
    [self.view addSubview:_loadingView];
}

- (void)stopLoading
{
    if([self isLoading]) {
        [_loadingView removeFromSuperview];
        _loadingView = nil;
    }
}

@end
