//
//  ChangePWDViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/21.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "ChangePWDViewController.h"
#import "FindPWDViewController.h"

@interface ChangePWDViewController () <UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@end

@implementation ChangePWDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"修改密码";
    
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

- (IBAction)submitAction:(id)sender {
    NSLog(@"提交修改");
    [self.oldPwdTF resignFirstResponder];
    [self.onenewPwdTF resignFirstResponder];
    [self.renewPwdTF resignFirstResponder];
    
    NSString *loginPWD = [[GlobalSetting shareGlobalSettingInstance] loginPWD];
    if ([self.oldPwdTF.text isEqualToString:loginPWD]) {
        if ([self.renewPwdTF.text isEqualToString:self.onenewPwdTF.text]) {
            [self requestModifyPwd];
        }
        else {
            _networkConditionHUD.labelText = @"两次输入的密码不一致！";
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
    }
    else {
        _networkConditionHUD.labelText = @"输入的密码错误！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}

- (IBAction)forgetAction:(id)sender {
    FindPWDViewController *findVC = [[FindPWDViewController alloc] init];
    [self.navigationController pushViewController:findVC animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.oldPwdTF resignFirstResponder];
    [self.onenewPwdTF resignFirstResponder];
    [self.renewPwdTF resignFirstResponder];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSLog(@"text: %@",text);
    
    if ([self.oldPwdTF.text length] >= 6 && [self.onenewPwdTF.text length] >= 6 && [text length] >= 6) {
        self.submitBtn.enabled = YES;
        [self.submitBtn setBackgroundColor:Red_BtnColor];
    }
    else {
        self.submitBtn.enabled = NO;
        [self.submitBtn setBackgroundColor:Gray_BtnColor];
    }
    
    return YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        [self.navigationController popViewControllerAnimated:YES]; //返回上级页面
    }
}

#pragma mark - 发送请求
-(void)requestModifyPwd { //修改密码
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ModifyPwd object:nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ModifyPwd, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userID,@"member_id",self.oldPwdTF.text,@"old_pwd",self.renewPwdTF.text,@"new_pwd",nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(ModifyPwd) delegate:nil params:pram info:infoDic];
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
    
    if ([notification.name isEqualToString:ModifyPwd]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ModifyPwd object:nil];

        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
//            _networkConditionHUD.labelText = responseObject [MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            [[GlobalSetting shareGlobalSettingInstance] setLoginPWD:self.onenewPwdTF.text]; //更新存储的新登录密码
            
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
