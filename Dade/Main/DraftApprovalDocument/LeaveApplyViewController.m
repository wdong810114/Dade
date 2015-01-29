//
//  LeaveApplyViewController.m
//  Dade
//
//  Created by 王冬冬 on 15-1-28.
//  Copyright (c) 2015年 Spark. All rights reserved.
//

#import "LeaveApplyViewController.h"

@interface LeaveApplyViewController ()

- (void)initView;
- (BOOL)checkValidity;
- (void)report;
- (void)removePickerPanel;

@end

@implementation LeaveApplyViewController
{
    UIView *_leaveTypePickerPanel;
    UIPickerView *_leaveTypePickerView;
    NSArray *_leaveTypes;   // 请假类别
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
        
        _leaveTypes = @[@"事假", @"病假", @"年假", @"产假", @"婚假", @"丧假", @"其他"];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setNavigationBar
{
    [super setNavigationBar];
    
    [self setNavigationBarTitle:@"请假申请"];
    [self setLeftBarButtonItem:@selector(backClicked:) image:@"back_icon_n" highlightedImage:@"back_icon_p"];
}

- (void)backClicked:(UIButton *)button
{
    [self pop];
}

- (void)leaveTypeClicked
{
    // 请假类别
    
    [self.view endEditing:YES];

    if(!_leaveTypePickerPanel) {
        _leaveTypePickerPanel = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height, self.view.frame.size.width, 216.0 + 44.0)];
        _leaveTypePickerPanel.backgroundColor = [UIColor whiteColor];
        
        UIToolbar *toolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0, 0.0, _leaveTypePickerPanel.frame.size.width, 44.0)];
        toolbar.barStyle = UIBarStyleDefault;
        UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(doneClicked)];
        NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
        toolbar.items = buttonArray;
        
        UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0.0, 44.0, _leaveTypePickerPanel.frame.size.width, 216.0)];
        pickerView.delegate = self;
        pickerView.dataSource = self;
        pickerView.showsSelectionIndicator = YES;
        _leaveTypePickerView = pickerView;
        
        [_leaveTypePickerPanel addSubview:toolbar];
        [_leaveTypePickerPanel addSubview:pickerView];
        [self.view addSubview:_leaveTypePickerPanel];
    }

    [UIView animateWithDuration:0.25
                     animations:^{
                         CGRect frame = _leaveTypePickerPanel.frame;
                         frame.origin.y = self.view.frame.size.height - frame.size.height;
                         _leaveTypePickerPanel.frame = frame;
                     } completion:^(BOOL finished) {
                     }];

    CGFloat maxOffsetY = self.leaveTypeView.frame.origin.y;
    CGFloat minOffsetY = self.leaveTypeView.frame.origin.y + self.leaveTypeView.frame.size.height + _leaveTypePickerPanel.frame.size.height - self.leaveApplyScrollView.frame.size.height;
    if(maxOffsetY < self.leaveApplyScrollView.contentOffset.y) {
        [self.leaveApplyScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.leaveApplyScrollView.contentOffset.y < minOffsetY) {
        [self.leaveApplyScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)doneClicked
{
    self.leaveTypeLabel.text = [_leaveTypes objectAtIndex:[_leaveTypePickerView selectedRowInComponent:0]];
    
    [self removePickerPanel];
}

- (IBAction)reportButtonClicked:(UIButton *)button
{
    // 呈报
    
    [self report];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    CGRect keyboardFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat maxOffsetY, minOffsetY;
    
    if([self.leaveDateTextField isFirstResponder]) {
        maxOffsetY = self.leaveDateView.frame.origin.y;
        minOffsetY = self.leaveDateView.frame.origin.y + self.leaveDateView.frame.size.height + keyboardFrame.size.height - self.leaveApplyScrollView.frame.size.height;
    } else if([self.contentTextView isFirstResponder]) {
        maxOffsetY = self.contentView.frame.origin.y;
        minOffsetY = self.contentView.frame.origin.y + self.contentView.frame.size.height + keyboardFrame.size.height - self.leaveApplyScrollView.frame.size.height;
    } else if([self.explainTextView isFirstResponder]) {
        maxOffsetY = self.explainView.frame.origin.y;
        minOffsetY = self.explainView.frame.origin.y + self.explainView.frame.size.height + keyboardFrame.size.height - self.leaveApplyScrollView.frame.size.height;
    }
    
    if(maxOffsetY < self.leaveApplyScrollView.contentOffset.y) {
        [self.leaveApplyScrollView setContentOffset:CGPointMake(0.0, maxOffsetY) animated:YES];
    }
    if(self.leaveApplyScrollView.contentOffset.y < minOffsetY) {
        [self.leaveApplyScrollView setContentOffset:CGPointMake(0.0, minOffsetY) animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGFloat scrollMaxOffsetY = self.leaveApplyScrollView.contentSize.height - self.leaveApplyScrollView.frame.size.height;
    if(self.leaveApplyScrollView.contentOffset.y > scrollMaxOffsetY) {
        [self.leaveApplyScrollView setContentOffset:CGPointMake(0.0, scrollMaxOffsetY) animated:YES];
    }
}

- (void)dismissKeyboard
{
    if([self.contentTextView isFirstResponder]) {
        [self.contentTextView resignFirstResponder];
    } else if([self.explainTextView isFirstResponder]) {
        [self.explainTextView resignFirstResponder];
    }
}

#pragma mark - Private Methods
- (void)initView
{
    if(!IOS_VERSION_7_OR_ABOVE) {
        self.subjectLabel.preferredMaxLayoutWidth = self.subjectLabel.bounds.size.width;
        self.senderLabel.preferredMaxLayoutWidth = self.senderLabel.bounds.size.width;
        self.departmentLabel.preferredMaxLayoutWidth = self.departmentLabel.bounds.size.width;
        self.positionLabel.preferredMaxLayoutWidth = self.positionLabel.bounds.size.width;
    }
    
    self.leaveTypeLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leaveTypeClicked)];
    [self.leaveTypeLabel addGestureRecognizer:tapGestureRecognizer];
    
    self.arrowImageView.image = [UIImage imageNamed:@"down_arrow"];

    [self.reportButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_NORMAL_COLOR] forState:UIControlStateNormal];
    [self.reportButton setBackgroundImage:[Util imageWithColor:RED_BUTTON_BG_HIGHLIGHTED_COLOR] forState:UIControlStateHighlighted];
    [self.reportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UIToolbar *inputAccessoryView = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0, 0.0, DEVICE_WIDTH, INPUT_ACCESSORY_VIEW_HEIGHT)];
    inputAccessoryView.barStyle = UIBarStyleDefault;
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:BUTTON_TITLE_DONE style:UIBarButtonItemStyleDone target:self action:@selector(dismissKeyboard)];
    NSArray *buttonArray = [NSArray arrayWithObjects:flexibleSpace, doneButton, nil];
    inputAccessoryView.items = buttonArray;
    self.contentTextView.inputAccessoryView = inputAccessoryView;
    self.explainTextView.inputAccessoryView = inputAccessoryView;
    
    // 测试---Start
    self.subjectLabel.text = @"我要请假我要请假我要请假我要请假我要请假我要请假我要请假我要请假";
    self.senderLabel.text = @"王冬王冬冬王冬冬王冬冬王冬冬王冬冬王冬冬王冬冬王冬冬";
    self.departmentLabel.text = @"综合管理部综合管理部综合管理部综合管理部综合管理部综合管理部综合管理部综合管理部";
    self.positionLabel.text = @"员工员工员工员工员工员工员工员工员工员工员工员工员工员工";
    // 测试---End
}

- (BOOL)checkValidity
{
    if([[Util trimString:self.leaveDateTextField.text] isEqualToString:@""]) {
        [self showAlert:@"请假日期不能为空"];
        
        return NO;
    }
    
    if([[Util trimString:self.contentTextView.text] isEqualToString:@""] ||
       [[Util trimString:self.explainTextView.text] isEqualToString:@""]) {
        [self showAlert:@"内容不能为空"];
        
        return NO;
    }
    
    return YES;
}

- (void)report
{
    if([self checkValidity]) {
        [self.view endEditing:YES];
        
    }
}

- (void)removePickerPanel
{
    if(_leaveTypePickerPanel) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             CGRect frame = _leaveTypePickerPanel.frame;
                             frame.origin.y = self.view.frame.size.height;
                             _leaveTypePickerPanel.frame = frame;
                         } completion:^(BOOL finished) {
                         }];
    }
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.view endEditing:YES];

    [self removePickerPanel];
}

#pragma mark - UITextFieldDelegate Methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self removePickerPanel];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == self.leaveDateTextField) {
        [self.leaveDateTextField resignFirstResponder];
    }
    
    return YES;
}

#pragma mark - UITextViewDelegate Methods
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [self removePickerPanel];
    
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
    } else if(textView == self.explainTextView) {
        if([Util isEmptyString:self.explainTextView.text]) {
            self.explainPlaceholderLabel.alpha = 1.0;
        } else {
            self.explainPlaceholderLabel.alpha = 0.0;
        }
    }
}

#pragma mark - UIPickerViewDataSource Methods
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_leaveTypes count];
}

#pragma mark - UIPickerViewDelegate Methods
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_leaveTypes objectAtIndex:row];
}

@end
