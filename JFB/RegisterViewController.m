//
//  RegisterViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/21.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "RegisterViewController.h"
#import "ScanCodeViewController.h"
#import "WebViewController.h"

#define LEFTTIME    120   //120秒限制

@interface RegisterViewController () <ScanCodeDelegate,UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSString *certCode;
    NSString *smstypeStr;   //验证码类型
    
    NSInteger leftTime;
    NSTimer *_timer;
}

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"快速注册";
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

- (IBAction)scanAction:(id)sender {
    ScanCodeViewController *scanCodeVC = [[ScanCodeViewController alloc] init];
    scanCodeVC.delegate = self;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:scanCodeVC];
    nav.hidesBottomBarWhenPushed = YES;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)radioAction:(id)sender {
    self.radioBtn.selected = ! self.radioBtn.selected;
}

- (IBAction)protocolAction:(id)sender {
    WebViewController *web = [[WebViewController alloc] init];
    web.webUrlStr = ActivityUrl(UserAgreement);
    web.titleStr = @"积分宝协议";
    web.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:web animated:YES];
}

- (IBAction)reSendAction:(id)sender {
    smstypeStr = @"0";  //短信验证码
    [self verifyAndSend];
}

- (IBAction)yuyinAction:(id)sender {
    smstypeStr = @"1";  //语音验证码
    [self verifyAndSend];
}

-(void)verifyAndSend {
    if ([[GlobalSetting shareGlobalSettingInstance] validatePhone:self.phoneTF.text]) {  //手机号码格式正确
        if (certCode) {     //code已存在，说明曾发送过验证码，手机号码可用
            [self requestSendSMSVerifyCode];
        }
        else {
            [self requestVerifyMobile];
        }
    }
    else {
        _networkConditionHUD.labelText = @"请输入正确的手机号码！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

- (IBAction)confirmAction:(id)sender {
    [self.phoneTF resignFirstResponder];
    [self.carAddressTF resignFirstResponder];
    [self.codeNumTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.rePasswordTF resignFirstResponder];
    
    if (! self.radioBtn.selected) {
        _networkConditionHUD.labelText = @"您同意《积分宝用户协议》后才能注册！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (! [self.codeNumTF.text isEqualToString:certCode]) {
        _networkConditionHUD.labelText = @"验证码输入不正确";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    
    [self requestMemberRegister];
}


#pragma mark - ScanCodeDelegate
- (void)ScanCodeComplete:(NSString *)codeString {   //商户ID二维码，需去除http://wx.jfb315.com/UserCenter/Reg.aspx?uid=
    NSString *merchantidStr = [codeString stringByReplacingOccurrencesOfString:@"http://wx.jfb315.com/UserCenter/Reg.aspx?uid=" withString:@""];
    self.carAddressTF.text = merchantidStr;
}

- (void)ScanCodeError:(NSError *)error {
    
}


/**
 *  改变剩余时间
 *
 *  @param timer
 */
-(void) changeLeftTime:(NSTimer *)timer{
    if ([smstypeStr intValue] == 0) { //短信验证码
        if (leftTime == 0) {
            self.reSendBtn.enabled = YES;
            [_timer invalidate];
            NSString *string = [NSString stringWithFormat:@"重新发送"];
            [self.reSendBtn setTitle:string forState:UIControlStateNormal];
            return;
        }
        leftTime --;
        NSString *string = [NSString stringWithFormat:@"(%ldS)重新发送",(long)leftTime];
        [self.reSendBtn setTitle:string forState:UIControlStateNormal];
    }
    else if ([smstypeStr intValue] == 1) {  //语音验证码
        if (leftTime == 0) {
            self.yuyinBtn.enabled = YES;
            [_timer invalidate];
            NSString *string = [NSString stringWithFormat:@"重新获取语音验证码"];
            [self.yuyinBtn setTitle:string forState:UIControlStateNormal];
            return;
        }
        leftTime --;
        NSString *string = [NSString stringWithFormat:@"(%ldS)重新获取语音验证码",(long)leftTime];
        [self.yuyinBtn setTitle:string forState:UIControlStateNormal];
    }
}


#pragma mark - UITextFieldDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
//    NSLog(@"text: %@",text);
//    if (textField == self.phoneTF) {
//        if ([text length] >= 11) {
//            self.reSendBtn.enabled = YES;
////            [self.reSendBtn setBackgroundColor:Red_BtnColor];
//        }
//        else {
//            self.reSendBtn.enabled = NO;
////            [self.reSendBtn setBackgroundColor:Gray_BtnColor];
//        }
//    }
//    
////    else if (textField == self.codeNumTF) {
////        if ([text length] >= 4) {
////            self.checkBtn.enabled = YES;
////            [self.checkBtn setBackgroundColor:Red_BtnColor];
////        }
////        else {
////            self.checkBtn.enabled = NO;
////            [self.checkBtn setBackgroundColor:Gray_BtnColor];
////        }
////    }
//    
////    else if (textField == self.rePasswordTF) {
////        if ([text length] >= 6) {
////            self.confirmBtn.enabled = YES;
////            [self.confirmBtn setBackgroundColor:Red_BtnColor];
////        }
////        else {
////            self.confirmBtn.enabled = NO;
////            [self.confirmBtn setBackgroundColor:Gray_BtnColor];
////        }
////    }
//
//    return YES;
//}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.passwordTF]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 40, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    if ([textField isEqual:self.rePasswordTF]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -20, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    if ([textField isEqual:self.carAddressTF]) {
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, -55, self.view.frame.size.width, self.view.frame.size.height);
        }];
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.phoneTF resignFirstResponder];
    [self.carAddressTF resignFirstResponder];
    [self.codeNumTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.rePasswordTF resignFirstResponder];
    
    return YES;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView animateWithDuration:0.3 animations:^{
            self.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height);
        }];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.phoneTF resignFirstResponder];
    [self.carAddressTF resignFirstResponder];
    [self.codeNumTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.rePasswordTF resignFirstResponder];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.phoneTF resignFirstResponder];
    [self.carAddressTF resignFirstResponder];
    [self.codeNumTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self.rePasswordTF resignFirstResponder];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        [self.navigationController popViewControllerAnimated:YES]; //返回登录页面
    }
}

#pragma mark - 发送请求
-(void)requestVerifyMobile { //验证是否已注册
    [_hud show:YES];
    
    [self.phoneTF resignFirstResponder];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:VerifyMobile object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:VerifyMobile, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.phoneTF.text,@"mobile", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(VerifyMobile) delegate:nil params:pram info:infoDic];
}

-(void)requestSendSMSVerifyCode { //发送验证码
    [_hud show:YES];
    
    [self.phoneTF resignFirstResponder];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:SendSMSVerifyCodeNew object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:SendSMSVerifyCodeNew, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.phoneTF.text,@"mobile",smstypeStr,@"smstype", nil]; //   smstype: 0是普通验证码 1是语音验证码
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(SendSMSVerifyCodeNew) delegate:nil params:pram info:infoDic];
}

-(void)requestMemberRegister { //注册
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MemberRegister object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MemberRegister, @"op", nil];
    NSString *uIdStr = self.carAddressTF.text;
    if (self.carAddressTF.text == nil || [self.carAddressTF.text isEqualToString:@""]) {
        uIdStr = @"";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.phoneTF.text,@"mobile",self.passwordTF.text,@"pwd",uIdStr,@"uId", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(MemberRegister) delegate:nil params:pram info:infoDic];
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
    NSLog(@"GetMerchantList_responseObject: %@",responseObject);
    
    if ([notification.name isEqualToString:SendSMSVerifyCodeNew]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SendSMSVerifyCodeNew object:nil];
        if ([responseObject[@"status"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            certCode = responseObject[DATA][@"certCode"];
            
            self.reSendBtn.enabled = NO;
            self.yuyinBtn.enabled = NO;
            leftTime = LEFTTIME;
            _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeLeftTime:) userInfo:nil repeats:YES];
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"发送短信" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
        
    }
    if ([notification.name isEqualToString:VerifyMobile]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:VerifyMobile object:nil];
        if ([responseObject[DATA][@"isExist"] boolValue]) {  //已注册
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
        else {
            [self requestSendSMSVerifyCode];
        }
    }
    
    if ([notification.name isEqualToString:MemberRegister]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MemberRegister object:nil];
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
