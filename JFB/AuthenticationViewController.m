//
//  AuthenticationViewController.m
//  JFB
//
//  Created by LYD on 15/8/20.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "AuthenticationViewController.h"
#import "HZAreaPickerView.h"
#import "NSString+Check.h"
#import "WebViewController.h"

@interface AuthenticationViewController () <HZAreaPickerDelegate,UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
//    NSString *_provinceStr;
//    NSString *_cityStr;
//    NSString *_disStr;
//    BOOL isModifyMemberInfo; //是否调用修改会员邮箱信息接口
    NSString *_locationStr;
}

@property (nonatomic, strong) MBProgressHUD *networkConditionHUD;
@property (strong, nonatomic) HZAreaPickerView *locatePicker;

@end

@implementation AuthenticationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = self.titleStr;
    
//    isModifyMemberInfo = NO;
    _locationStr = @"";     //默认是空字符串
    
    if (self.isAuthenticated) { //已认证，该页作为编辑页，只能更改email
        self.nameTF.text = [[GlobalSetting shareGlobalSettingInstance] mName];
        self.nameTF.enabled = NO;
        self.identityCardTF.text = [[GlobalSetting shareGlobalSettingInstance] mIdentityId];
        self.identityCardTF.enabled = NO;
        
        NSString *locationStr = [[GlobalSetting shareGlobalSettingInstance] mlocation];
//        if ([locationStr isEqualToString:@""]) {
            self.provCityTF.enabled = YES;
//            isModifyMemberInfo = YES;
//        }
//        else {
//            self.provCityTF.enabled = NO;
//            isModifyMemberInfo = YES;
//        }
        self.provCityTF.text = locationStr;

        self.emailTF.text = [[GlobalSetting shareGlobalSettingInstance] mEmail];
        self.emailTF.enabled = YES;
        [self.submitBtn setTitle:@"提交修改" forState:UIControlStateNormal];
    }
    else {
        self.nameTF.enabled = YES;
        self.identityCardTF.enabled = YES;
        self.provCityTF.enabled = YES;
        self.emailTF.enabled = YES;
        [self.submitBtn setTitle:@"申请认证" forState:UIControlStateNormal];
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


#pragma mark - TextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.provCityTF]) {
        [self.nameTF resignFirstResponder];
        [self.identityCardTF resignFirstResponder];
        [self.emailTF resignFirstResponder];
        
        [self cancelLocatePicker];
        self.locatePicker = [[HZAreaPickerView alloc] initWithDelegate:self];
        [self.locatePicker.completeBarBtn setTarget:self];
        [self.locatePicker.completeBarBtn setAction:@selector(resignKeyboard)];
        self.locatePicker.frame = CGRectMake(0, 0, SCREEN_WIDTH, 238);
        [self.locatePicker showInView:self.view];
        
        return NO;
    }
    
    if ([textField isEqual:self.emailTF]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.emailTF]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self cancelLocatePicker];
    [self.nameTF resignFirstResponder];
    [self.identityCardTF resignFirstResponder];
    [self.emailTF resignFirstResponder];
}

-(void)resignKeyboard{ //回收键盘
    [self cancelLocatePicker];
}

#pragma mark - HZAreaPicker delegate
-(void)pickerDidChaneStatus:(HZAreaPickerView *)picker
{
    self.provCityTF.text = [NSString stringWithFormat:@"%@ %@ %@", picker.state, picker.city, picker.district];
    
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

- (IBAction)submitAction:(id)sender
{
    [self cancelLocatePicker];
    [self.nameTF resignFirstResponder];
    [self.identityCardTF resignFirstResponder];
    [self.emailTF resignFirstResponder];
    
    if (! self.radioBtn.selected) {
        _networkConditionHUD.labelText = @"您同意《投保协议》后才能认证！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    
    if (self.nameTF.text == nil || self.nameTF.text.length == 0) {
        _networkConditionHUD.labelText = @"请填写姓名！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (self.identityCardTF.text == nil || self.identityCardTF.text.length == 0) {
        _networkConditionHUD.labelText = @"请填写身份证号！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    BOOL isIdentityCard = [NSString validateIdentityCard:self.identityCardTF.text];
    if (! isIdentityCard) {
        _networkConditionHUD.labelText = @"请填写正确的身份证号！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (self.provCityTF.text == nil || self.provCityTF.text.length == 0) {
        _networkConditionHUD.labelText = @"请选择地区！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (self.isAuthenticated) {
        [self toModifyMemberInfo];
    }
    else {
        [self toMemberActivate];
    }
}
- (IBAction)radioAction:(id)sender {
    self.radioBtn.selected = ! self.radioBtn.selected;
}
- (IBAction)agreementAction:(id)sender {
    WebViewController *web = [[WebViewController alloc] init];
    web.webUrlStr = ActivityUrl(UserAgreement);
    web.titleStr = @"积分宝协议";
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        [self.navigationController popViewControllerAnimated:YES]; //返回上级页面
    }
}

#pragma mark - 发送请求
//会员实名认证
-(void)toMemberActivate
{
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MemberActivate object:nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSString *emailStr = self.emailTF.text;
    if (emailStr == nil || [emailStr isEqualToString:@""]) {
        emailStr = @"";
    }
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MemberActivate, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.identityCardTF.text,@"id_card",[[GlobalSetting shareGlobalSettingInstance] mMobile],@"mobile",emailStr,@"email",self.nameTF.text,@"name",_locationStr,@"location", nil];
    NSLog(@"toMemberActivate_pram:%@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(MemberActivate) delegate:nil params:pram info:infoDic];
}


//会员信息修改
-(void)toModifyMemberInfo
{
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ModifyMemberInfo object:nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSString *emailStr = self.emailTF.text;
    if (emailStr == nil || [emailStr isEqualToString:@""]) {
        emailStr = @"";
    }
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ModifyMemberInfo, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:emailStr,@"email",userID,@"mId",_locationStr,@"location", nil];
    NSLog(@"toModifyMemberInfo_pram:%@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(ModifyMemberInfo) delegate:nil params:pram info:infoDic];
}

#pragma mark - 发送请求
-(void)requestMemberReLogin { //登录
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MemberLogin object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MemberLogin, @"op", nil];
    NSString *mobilStr = [[GlobalSetting shareGlobalSettingInstance] mMobile];
    NSString *pwdStr = [[GlobalSetting shareGlobalSettingInstance] loginPWD];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:mobilStr,@"username",pwdStr,@"password", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(MemberLogin) delegate:nil params:pram info:infoDic];
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
    
    if ([notification.name isEqualToString:MemberActivate]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MemberActivate object:nil];
        
        NSLog(@"MemberActivate_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
            _networkConditionHUD.labelText = responseObject [MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            //延迟0.2秒调用重新登录操作，刷新个人信息
            [self performSelector:@selector(requestMemberReLogin) withObject:nil afterDelay:0.2];
            
//            [self.navigationController popViewControllerAnimated:YES]; //返回上级页面
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:ModifyMemberInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ModifyMemberInfo object:nil];
        
        NSLog(@"MemberActivate_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
            _networkConditionHUD.labelText = responseObject [MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            //延迟0.2秒调用重新登录操作，刷新个人信息
            [self performSelector:@selector(requestMemberReLogin) withObject:nil afterDelay:0.2];
            
//            [self.navigationController popViewControllerAnimated:YES]; //返回上级页面
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:MemberLogin]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MemberLogin object:nil];
        if ([responseObject[@"status"] boolValue]) {
//            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            NSDictionary *dic = responseObject[DATA];
//            [[GlobalSetting shareGlobalSettingInstance] setLoginPWD:self.passwordTF.text]; //存储登录密码
            [[GlobalSetting shareGlobalSettingInstance] setIsLogined:YES];  //已登录标示
            [[GlobalSetting shareGlobalSettingInstance] setUserID:dic [@"mId"]];
            [[GlobalSetting shareGlobalSettingInstance] setAuthenticate:dic [@"authenticate"]];    //是否认证
            [[GlobalSetting shareGlobalSettingInstance] setIsChangeCard:dic [@"isChangeCard"]];   //是否可更换会员卡
            [[GlobalSetting shareGlobalSettingInstance] setmBinding:dic [@"mBinding"]];
            [[GlobalSetting shareGlobalSettingInstance] setmMobile:dic [@"mMobile"]];
            [[GlobalSetting shareGlobalSettingInstance] setPension:dic [@"pension"]];
            [[GlobalSetting shareGlobalSettingInstance] setcId:dic [@"cId"]];
            [[GlobalSetting shareGlobalSettingInstance] setOrganizationID:dic [@"oId"]];
            [[GlobalSetting shareGlobalSettingInstance] setmName:dic [@"mName"]];
            [[GlobalSetting shareGlobalSettingInstance] setmIdentityId:dic [@"mIdentityId"]];
            [[GlobalSetting shareGlobalSettingInstance] setmEmail:dic [@"mEmail"]];
            [[GlobalSetting shareGlobalSettingInstance] setmlocation:dic [@"location"]];
            
            //            [[GlobalSetting shareGlobalSettingInstance] setUserInfo:responseObject[DATA]];
            
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            alert.tag = 1000;
            [alert show];
            
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
