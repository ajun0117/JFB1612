//
//  LoginViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/21.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "FindPWDViewController.h"

@interface LoginViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"登录";
    UIButton *rightButn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButn.frame = CGRectMake(0, 0, 60, 26);
    rightButn.contentMode = UIViewContentModeScaleAspectFit;
    rightButn.titleLabel.font = [UIFont systemFontOfSize:13];
    [rightButn setTitle:@"忘记密码" forState:UIControlStateNormal];
    [rightButn addTarget:self action:@selector(findPWD) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButn = [[UIBarButtonItem alloc] initWithCustomView:rightButn];
    self.navigationItem.rightBarButtonItem = rightBarButn;
    
    [self.phoneTF setLeftView:@"login_user" placeholder:@"手机号码/身份证/卡号"];
    [self.passwordTF setLeftView:@"login_key" placeholder:@"密码"];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
    
}
- (IBAction)loginAction:(id)sender {
    [self.phoneTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
    [self requestMemberLogin];
}

- (IBAction)registerAction:(id)sender {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}


-(void)findPWD {
    FindPWDViewController *findVC = [[FindPWDViewController alloc] init];
    [self.navigationController pushViewController:findVC animated:YES];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.phoneTF resignFirstResponder];
    [self.passwordTF resignFirstResponder];
}


#pragma mark - 发送请求
-(void)requestMemberLogin { //登录
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:MemberLogin object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:MemberLogin, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.phoneTF.text,@"username",self.passwordTF.text,@"password", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(MemberLogin) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        if (!_networkConditionHUD) {
            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_networkConditionHUD];
        }
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        _networkConditionHUD.mode = MBProgressHUDModeText;
        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        _networkConditionHUD.margin = HUDMargin;
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    NSLog(@"GetMerchantList_responseObject: %@",responseObject);
    
    if ([notification.name isEqualToString:MemberLogin]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:MemberLogin object:nil];
        if ([responseObject[@"status"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            NSDictionary *dic = responseObject[DATA];
            [[GlobalSetting shareGlobalSettingInstance] setLoginPWD:self.passwordTF.text]; //存储登录密码
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
            
            
            [self.navigationController popViewControllerAnimated:YES]; //返回登录页面
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
