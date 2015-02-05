//
//  NoticeDraftViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "NoticeDraftViewController.h"

@interface NoticeDraftViewController ()

- (void)initView;
- (BOOL)checkValidity;

- (void)draftNoticeInfo;
- (void)requestDraftNoticeInfoFinished:(ASIHTTPRequest *)request;
- (void)requestDraftNoticeInfoFailed:(ASIHTTPRequest *)request;

@end

@implementation NoticeDraftViewController
{
    CGPoint _scrollViewContentOffset;   // 解决iOS6下bug
        
    NSArray *_recipientIdArray;
    BOOL _isFeedback;
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
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.noticeDraftScrollView.contentOffset = CGPointZero;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    _scrollViewContentOffset = self.noticeDraftScrollView.contentOffset;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.noticeDraftScrollView.contentOffset = _scrollViewContentOffset;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"通知起草"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    if([self isRequesting]) {
        return;
    }
    
    [self pop];
}

- (IBAction)addButtonClicked:(UIButton *)button
{
    // 添加
    
    if([self isRequesting]) {
        return;
    }
    
    PersonnelListViewController *viewController = [[PersonnelListViewController alloc] initWithNibName:@"PersonnelListViewController" bundle:nil];
    viewController.delegate = self;
    viewController.selectedIdArray = [NSMutableArray arrayWithArray:_recipientIdArray];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (IBAction)sendButtonClicked:(UIButton *)button
{
    // 发送
    
    if([self isRequesting]) {
        return;
    }
    
    [self draftNoticeInfo];
}

- (void)feedbackClicked
{
    // 完结回馈
    
    if([self isRequesting]) {
        return;
    }
    
    [self.view endEditing:YES];
    
    _isFeedback = !_isFeedback;
    self.checkImageView.image = _isFeedback ? [UIImage imageNamed:@"row_selected_icon"] : [UIImage imageNamed:@"row_unselected_icon"];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.subjectTextField isFirstResponder]) {
        maxOffsetY = self.subjectView.frame.origin.y;
        minOffsetY = self.subjectView.frame.origin.y + self.subjectView.frame.size.height + keyboardFrame.size.height - self.noticeDraftScrollView.frame.size.height;
    } else if([self.contentTextView isFirstResponder]) {
        maxOffsetY = self.contentView.frame.origin.y;
        minOffsetY = self.contentView.frame.origin.y + self.contentView.frame.size.height + keyboardFrame.size.height - self.noticeDraftScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.noticeDraftScrollView.contentOffset.y) {
        [self.noticeDraftScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.noticeDraftScrollView.contentOffset.y < minOffsetY) {
        [self.noticeDraftScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat scrollMaxOffsetY = self.noticeDraftScrollView.contentSize.height - self.noticeDraftScrollView.frame.size.height;
    if(self.noticeDraftScrollView.contentOffset.y > scrollMaxOffsetY) {
        if(scrollMaxOffsetY < 0) {
            [self.noticeDraftScrollView setContentOffset:CGPointZero animated:YES];
        } else {
            [self.noticeDraftScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
        }
    }
}

- (void)dismissKeyboard
{
    if([self.contentTextView isFirstResponder]) {
        [self.contentTextView resignFirstResponder];
    }
}

#pragma mark - Private Methods
- (void)initView
{
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.recipientsLabel.preferredMaxLayoutWidth = self.recipientsLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
    }
    
    self.departmentLabel.text = DadeAppDelegate.userInfo.department;
    
    self.feedbackLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(feedbackClicked)];
    [self.feedbackLabel addGestureRecognizer:tapGestureRecognizer];
    
    self.checkImageView.image = [UIImage imageNamed:@"row_unselected_icon"];
    
    [self.addButton setTitleColor:BLUE_BUTTON_TITLE_NORMAL_COLOR forState:UIControlStateNormal];
    [self.addButton setTitleColor:BLUE_BUTTON_TITLE_HIGHLIGHTED_COLOR forState:UIControlStateHighlighted];
    
    [self.sendButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIToolbar *inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, INPUT_ACCESSORY_VIEW_HEIGHT)];
    inputAccessoryView.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BAR_BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    inputAccessoryView.items = buttonArray;
    self.contentTextView.inputAccessoryView = inputAccessoryView;
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.subjectTextField.text] isEqualToString:@""]) {
        [self showAlert:@"题目不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.contentTextView.text] isEqualToString:@""]) {
        [self showAlert:@"内容不能为空"];
        
        return NO;
    }
    
    return YES;
}

- (void)draftNoticeInfo
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
        [self addLoadingView];
        
//        userId ：用户Id
//        fileTypeId: 文件类型Id
//        displayvalue：主题
//        filenum：编号
//        content：内容
//        staffIds：收件人(以“|”间隔)
//        temp：部门(由org_id|qyid|depOrgid组成，以“|”间隔)
//        isEnd：是否完结
        
        NSString *staffIds = [_recipientIdArray componentsJoinedByString:@"|"];
        NSString *temp = [NSString stringWithFormat:@"%@|%@|%@", DadeAppDelegate.userInfo.orgId, DadeAppDelegate.userInfo.qyId, DadeAppDelegate.userInfo.depOrgId];
        NSString *isEnd = _isFeedback ? @"1" : @"0";
        
        NSString *postString = [NSString stringWithFormat:@"{userId:'%@',fileTypeId:'5',displayvalue:'%@',filenum:'',content:'%@',staffIds:'%@',temp:'%@',isEnd:'%@'}", DadeAppDelegate.userInfo.staffId, self.subjectTextField.text, self.contentTextView.text, staffIds, temp, isEnd];
        NSMutableData *postData = [[NSMutableData alloc] initWithData:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        ASIFormDataRequest *request = [self requestWithRelativeURL:DRAFT_NOTICE_INFO_REQUEST_URL];
        [request setPostBody:postData];
        [self startRequest:request didFinishSelector:@selector(requestDraftNoticeInfoFinished:) didFailSelector:@selector(requestDraftNoticeInfoFailed:)];
    }
}

- (void)requestDraftNoticeInfoFinished:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    NSString *jsonString = request.responseString;
    
    NSError *error = nil;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if(!error && jsonDict) {
        NSString *ajaxToken = [jsonDict stringForKey:@"ajax_token"];
        if([ajaxToken integerValue] != 0) {
            NSString *ajaxMessage = [jsonDict stringForKey:@"ajax_message"];
            [self showAlert:ajaxMessage];
        } else {
            [self performSelector:@selector(pop)];
        }
    }
    
    [self requestDidFinish:request];
}

- (void)requestDraftNoticeInfoFailed:(ASIHTTPRequest *)request
{
    [self removeLoadingView];
    
    [self requestDidFail:request];
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if([self isRequesting]) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.subjectTextField) {
        [self.subjectTextField resignFirstResponder];
    }
    
    return YES;
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
    if(textView == self.contentTextView) {
        if([Util isEmptyString:self.contentTextView.text]) {
            self.contentPlaceholderLabel.alpha = 1.0;
        } else {
            self.contentPlaceholderLabel.alpha = 0.0;
        }
    }
}

#pragma mark - PersonnelListViewControllerDelegate Methods
- (void)personnelListViewController:(PersonnelListViewController *)personnelListViewController didSelectIds:(NSArray *)idArray didSelectNames:(NSArray *)nameArray
{
    _recipientIdArray = [NSArray arrayWithArray:idArray];
    self.recipientsLabel.text = [nameArray componentsJoinedByString:@"|"];
}

@end
