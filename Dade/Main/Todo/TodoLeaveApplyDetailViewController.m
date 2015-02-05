//
//  TodoLeaveApplyDetailViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-2-5.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "TodoLeaveApplyDetailViewController.h"

@interface TodoLeaveApplyDetailViewController ()

- (void)initView;
- (BOOL)checkValidity;
- (void)updateSelectedRadio;

- (void)getIncomeViewById;
- (void)requestGetIncomeViewByIdFinished:(ASIHTTPRequest *)request;
- (void)requestGetIncomeViewByIdFailed:(ASIHTTPRequest *)request;

@end

@implementation TodoLeaveApplyDetailViewController
{
    NSInteger _selectedRadio;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    
    [self getIncomeViewById];
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

- (void)radioButtonClicked:(UITapGestureRecognizer *)gestureRecognizer
{
    NSInteger tag = gestureRecognizer.view.tag;
    _selectedRadio = tag - 100;
    
    [self updateSelectedRadio];
}

- (IBAction)verifyButtonClicked:(UIButton *)button
{
    // 审核
    
    if([self isRequesting]) {
        return;
    }
    
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.explainTextView isFirstResponder]) {
        maxOffsetY = self.explainView.frame.origin.y;
        minOffsetY = self.explainView.frame.origin.y + self.explainView.frame.size.height + keyboardFrame.size.height - self.todoDetailScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.todoDetailScrollView.contentOffset.y) {
        [self.todoDetailScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.todoDetailScrollView.contentOffset.y < minOffsetY) {
        [self.todoDetailScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat scrollMaxOffsetY = self.todoDetailScrollView.contentSize.height - self.todoDetailScrollView.frame.size.height;
    if(self.todoDetailScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            [self.todoDetailScrollView setContentOffset:CGPointZero animated:YES];
        } else {
            [self.todoDetailScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
        }
    }
}

- (void)dismissKeyboard
{
    [self.explainTextView resignFirstResponder];
}

#pragma mark - Private Methods
- (void)initView
{
    self.todoDetailScrollView.backgroundColor = COLOR(0xf5,0xf5,0xf5);
    
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.subjectLabel.preferredMaxLayoutWidth = self.subjectLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
        self.quartersLabel.preferredMaxLayoutWidth = self.quartersLabel.bounds.size.width;
        self.leaveDateLabel.preferredMaxLayoutWidth = self.leaveDateLabel.bounds.size.width;
        self.leaveTypeLabel.preferredMaxLayoutWidth = self.leaveTypeLabel.bounds.size.width;
        self.contentLabel.preferredMaxLayoutWidth = self.contentLabel.bounds.size.width;
    }
    
    [self.verifyButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.verifyButton setBackgroundImage:[Util imageWithColor:GRAY_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.verifyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    UIToolbar *inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, INPUT_ACCESSORY_VIEW_HEIGHT)];
    inputAccessoryView.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    inputAccessoryView.items = buttonArray;
    self.explainTextView.inputAccessoryView = inputAccessoryView;
    
    for(UIView *radioButton in self.radioButtonsView.subviews) {
        radioButton.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(radioButtonClicked:)];
        [radioButton addGestureRecognizer:tapGestureRecognizer];
    }
    
    [self updateSelectedRadio];
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.explainTextView.text] isEqualToString:@""]) {
        [self showAlert:@"流转说明不能为空"];
        
        return NO;
    }
    
    return YES;
}

- (void)updateSelectedRadio
{
    for(UIView *radioButton in self.radioButtonsView.subviews) {
        for(UIView *subview in radioButton.subviews) {
            if([subview isKindOfClass:[UIImageView class]]) {
                UIImageView *radioImageView = (UIImageView *)subview;
                if(_selectedRadio == radioButton.tag - 100) {
                    radioImageView.image = [UIImage imageNamed:@"row_selected_icon"];
                } else {
                    radioImageView.image = [UIImage imageNamed:@"row_unselected_icon"];
                }
            }
        }
    }
}

- (void)getIncomeViewById
{
    [self addLoadingView];
    
//    id：文件主表Id
    
    NSString *postString = [NSString stringWithFormat:@"{id:'%@'}", self.todoId];
    NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
    
    ASIFormDataRequest *request = [self requestWithRelativeURL:GET_INCOME_VIEW_BY_ID_REQUEST_URL];
    [request setPostBody:postData];
    [self startRequest:request didFinishSelector:@selector(requestGetIncomeViewByIdFinished:) didFailSelector:@selector(requestGetIncomeViewByIdFailed:)];
}

- (void)requestGetIncomeViewByIdFinished:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        self.subjectLabel.text = [jsonDict stringForKey:@"displayvalue"];
        self.departmentLabel.text = [jsonDict stringForKey:@"depname"];
        self.quartersLabel.text = [jsonDict stringForKey:@"orgName"];
        self.contentLabel.text = [jsonDict stringForKey:@"content"];
    }
    
    [self requestDidFinish:request];
}

- (void)requestGetIncomeViewByIdFailed:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    [self requestDidFail:request];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if([self isRequesting]) {
        return NO;
    }
    
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if(textView == self.explainTextView) {
        if([Util isEmptyString:self.explainTextView.text]) {
            self.explainPlaceholderLabel.alpha = 1.0;
        } else {
            self.explainPlaceholderLabel.alpha = 0.0;
        }
    }
}

@end
