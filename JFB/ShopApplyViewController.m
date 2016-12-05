//
//  ShopApplyViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/9/3.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "ShopApplyViewController.h"
#import "HZAreaPickerView.h"
#import "NSString+Check.h"

@interface ShopApplyViewController () <HZAreaPickerDelegate,UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
//    NSString *_provinceStr;
//    NSString *_cityStr;
//    NSString *_disStr;
    NSString *_locationStr;
}

@property (strong, nonatomic) HZAreaPickerView *locatePicker;

@end

@implementation ShopApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商户申请";
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

#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.regionTF]) {
        [self.shopNameTF resignFirstResponder];
        [self.shopContacterTF resignFirstResponder];
        [self.contactPhoneTF resignFirstResponder];
        
        [self cancelLocatePicker];
        self.locatePicker = [[HZAreaPickerView alloc] initWithDelegate:self];
        [self.locatePicker.completeBarBtn setTarget:self];
        [self.locatePicker.completeBarBtn setAction:@selector(resignKeyboard)];
        self.locatePicker.frame = CGRectMake(0, 0, SCREEN_WIDTH, 238);
        [self.locatePicker showInView:self.view];
    }
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self cancelLocatePicker];
    [self.shopNameTF resignFirstResponder];
    [self.shopContacterTF resignFirstResponder];
    [self.contactPhoneTF resignFirstResponder];
}

-(void)resignKeyboard{ //回收键盘
    [self cancelLocatePicker];
}

#pragma mark - HZAreaPicker delegate
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    self.regionTF.text = [NSString stringWithFormat:@"%@ %@ %@", picker.state, picker.city, picker.district];
    
//    _provinceStr = picker.state;
//    _cityStr = picker.city;
//    _disStr = picker.district;
    if (picker.districtID && ! [picker.districtID isEqualToString:@""]) {
        _locationStr = picker.districtID;
    }
    else if (picker.cityID && ! [picker.cityID isEqualToString:@""]) {
        _locationStr = picker.cityID;
    }
    else if (picker.stateID && ! [picker.stateID isEqualToString:@""]) {
        _locationStr = picker.stateID;
    }
}

-(void)cancelLocatePicker
{
    [self.locatePicker cancelPicker];
    self.locatePicker.delegate = nil;
    self.locatePicker = nil;
}


- (IBAction)submitAction:(id)sender {
    [self cancelLocatePicker];
    [self.shopNameTF resignFirstResponder];
    [self.shopContacterTF resignFirstResponder];
    [self.contactPhoneTF resignFirstResponder];
    
    if (self.shopNameTF.text == nil || [self.shopNameTF.text isEqualToString:@""]) {
        _networkConditionHUD.labelText = @"请输入不少于2个字的名称！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        
        return;
    }
    if (self.shopContacterTF.text == nil || [self.shopContacterTF.text isEqualToString:@""]) {
        _networkConditionHUD.labelText = @"请输入商家联系人！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        
        return;
    }
    
    if (self.contactPhoneTF.text == nil || [self.contactPhoneTF.text isEqualToString:@""]) {
        _networkConditionHUD.labelText = @"请输入商家联系电话！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        
        return;
    }
    
    BOOL isphoneNumber = [NSString checkPhoneNumWithPhone:self.contactPhoneTF.text];
    if (! isphoneNumber) {
        _networkConditionHUD.labelText = @"请填写正确的手机或电话号码！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        
        return;
    }
    
    if (self.regionTF.text == nil || [self.regionTF.text isEqualToString:@""]) {
        _networkConditionHUD.labelText = @"请选择您的地区信息！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        
        return;
    }
    
    [self toApply];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 发送请求
//商户申请
-(void)toApply
{
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MerchantApply object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MerchantApply, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.shopNameTF.text,@"shopname",self.shopContacterTF.text,@"shopuse",self.contactPhoneTF.text,@"shopphone",_locationStr,@"location", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(MerchantApply) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification
{
    [_hud hide:YES];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    
    if ([notification.name isEqualToString:MerchantApply]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MerchantApply object:nil];
        
        NSLog(@"MemberActivate_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
//            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1000;
            [alert show];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
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
