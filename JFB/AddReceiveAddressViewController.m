//
//  AddReceiveAddressViewController.m
//  JFB
//
//  Created by LYD on 15/8/21.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "AddReceiveAddressViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "HZAreaPickerView.h"
#import "NSString+Check.h"

@interface AddReceiveAddressViewController () <HZAreaPickerDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@property (strong, nonatomic) HZAreaPickerView *locatePicker;

@end

@implementation AddReceiveAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = self.titleStr;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAddress)];
    
    self.detailAddrTV.layer.cornerRadius = 5;
    self.detailAddrTV.layer.borderWidth = 1;
    self.detailAddrTV.layer.borderColor = RGBCOLOR(230, 230, 230).CGColor;
    
    if (self.addressDic != nil) {   //修改，展示详情
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存修改" style:UIBarButtonItemStylePlain target:self action:@selector(saveAddress)];
        self.nameTF.text = self.addressDic [@"consignee_name"];
        self.mobileTF.text = self.addressDic [@"mobile"];
        self.telTF.text = self.addressDic [@"tel"];
        self.regionTF.text = self.addressDic [@"provinceCity"];
        self.detailAddrTV.textColor = [UIColor blackColor];
        self.detailAddrTV.text = self.addressDic [@"address"];
        self.postcodeTF.text = self.addressDic [@"postcode"];
        BOOL isDefault = [self.addressDic [@"markAddress"] boolValue];
        if (isDefault) {
            self.markBtn.selected = YES;
        }
        else {
            self.markBtn.selected = NO;
        }
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    
    if (!_networkConditionHUD) {
        _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_networkConditionHUD];
    }
    _networkConditionHUD.mode = MBProgressHUDModeText;
    _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
    _networkConditionHUD.margin = HUDMargin;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (IBAction)defaultAddrAction:(id)sender {
    UIButton *btn = (UIButton *)sender;
    btn.selected = ! btn.selected;
}

-(void)saveAddress {
    BOOL isphoneNumber = [NSString checkPhoneNumWithPhone:self.mobileTF.text];
    if (! isphoneNumber) {
        if (!_networkConditionHUD) {
            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_networkConditionHUD];
        }
        _networkConditionHUD.labelText = @"请填写正确的手机或电话号码";
        _networkConditionHUD.mode = MBProgressHUDModeText;
        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        _networkConditionHUD.margin = HUDMargin;
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        
        return;
    }
    
    if (self.addressDic != nil) {  //修改地址
        [self requestModifyDeliveryAddressInfo];
    }
    else {  //新增地址
        [self requestAddDeliveryAddressInfo];
    }
}

#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.regionTF]) {
        [self.telTF resignFirstResponder];
        [self.mobileTF resignFirstResponder];
        [self.nameTF resignFirstResponder];
        [self.detailAddrTV resignFirstResponder];
        [self.postcodeTF resignFirstResponder];
        
        [self cancelLocatePicker];
        self.locatePicker = [[HZAreaPickerView alloc] initWithDelegate:self];
        [self.locatePicker.completeBarBtn setTarget:self];
        [self.locatePicker.completeBarBtn setAction:@selector(resignKeyboard)];
        self.locatePicker.frame = CGRectMake(0, 0, SCREEN_WIDTH, 238);
        [self.locatePicker showInView:self.view];
        
        return NO;
    }
    
    if ([textField isEqual:self.postcodeTF]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -100, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    
    return YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
        self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
    }];
}

#pragma mark -
#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView{
    [self cancelLocatePicker];
    if ([textView.text isEqualToString:@"最少5个字，最多60个字"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -50, self.view.frame.size.width, self.view.frame.size.height);
        }];
        
    }
}
- (void)textViewDidEndEditing:(UITextView *)textView{
    if ([[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        textView.text = @"最少5个字，最多60个字";
        textView.textColor = [UIColor lightGrayColor];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self cancelLocatePicker];
    
    [self.telTF resignFirstResponder];
    [self.mobileTF resignFirstResponder];
    [self.nameTF resignFirstResponder];
    [self.detailAddrTV resignFirstResponder];
    [self.postcodeTF resignFirstResponder];
}

-(void)resignKeyboard{ //回收键盘
    [self cancelLocatePicker];
}

#pragma mark - HZAreaPicker delegate
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    self.regionTF.text = [NSString stringWithFormat:@"%@ %@ %@", picker.state, picker.city, picker.district];
}

-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}

#pragma mark - 发送请求
-(void)requestAddDeliveryAddressInfo { //新增收货地址信息
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:AddDeliveryAddressInfo object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:AddDeliveryAddressInfo, @"op", nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSString *markAddress;
    if (self.markBtn.selected) {
        markAddress = @"1";
    }
    else {
        markAddress = @"0";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userID,@"member_id",self.nameTF.text,@"consignee_name",self.regionTF.text,@"provinceCity",self.detailAddrTV.text,@"address",self.postcodeTF.text,@"postcode",self.telTF.text,@"tel",self.mobileTF.text,@"mobile",markAddress,@"markAddress", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(AddDeliveryAddressInfo) delegate:nil params:pram info:infoDic];
}





-(void)requestModifyDeliveryAddressInfo { //修改收货地址信息
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ModifyDeliveryAddressInfo object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ModifyDeliveryAddressInfo, @"op", nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSString *markAddress;
    if (self.markBtn.selected) {
        markAddress = @"1";
    }
    else {
        markAddress = @"0";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.addressDic[@"id"],@"id",userID,@"member_id",self.nameTF.text,@"consignee_name",self.regionTF.text,@"provinceCity",self.detailAddrTV.text,@"address",self.postcodeTF.text,@"postcode",self.telTF.text,@"tel",self.mobileTF.text,@"mobile",markAddress,@"markAddress", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(ModifyDeliveryAddressInfo) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:AddDeliveryAddressInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AddDeliveryAddressInfo object:nil];
        
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        if ([responseObject[@"status"] boolValue]) {
            _networkConditionHUD.labelText = responseObject [MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            [self.navigationController popViewControllerAnimated:YES]; //添加成功自动返回列表页
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    
    else if ([notification.name isEqualToString:ModifyDeliveryAddressInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ModifyDeliveryAddressInfo object:nil];
        
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        if ([responseObject[@"status"] boolValue]) {
            _networkConditionHUD.labelText = responseObject [MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            [self.navigationController popViewControllerAnimated:YES]; //修改成功自动返回列表页
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
