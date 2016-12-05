//
//  MemberCardViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/23.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MemberCardViewController.h"

@interface MemberCardViewController () <UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@end

@implementation MemberCardViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if (self.isChangeCard) {
        self.title = @"更换实体卡";
        [self.confireBtn setTitle:@"更换" forState:UIControlStateNormal];
    }
    else {
        self.title = @"绑定实体卡";
        [self.confireBtn setTitle:@"绑定" forState:UIControlStateNormal];
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
- (IBAction)questionAction:(id)sender {
    self.cardBgView.hidden = NO;
    self.cardNoticeIM.hidden = NO;
}

- (IBAction)changeAction:(id)sender {
    if (self.cardNumTF.text == nil || self.cardNumTF.text.length == 0) {
        _networkConditionHUD.labelText = @"请正确填写卡号！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    if (self.codeTF.text == nil || self.codeTF.text.length == 0) {
        _networkConditionHUD.labelText = @"请正确填写激活码！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    
    [self requestCardPackageInquiry];   //卡套餐查询
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.cardNumTF resignFirstResponder];
    [self.codeTF resignFirstResponder];
    self.cardBgView.hidden = YES;
    self.cardNoticeIM.hidden = YES;
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1000) {
        [self.navigationController popViewControllerAnimated:YES]; //返回上级页面
    }
    else if (alertView.tag == 2000) {
        if (buttonIndex == 1) {
            [self requestExchangeCard];
        }
    }
}

#pragma mark - 发送请求
-(void)requestCardPackageInquiry { //卡套餐查询
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:CardPackageInquiry object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:CardPackageInquiry, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.cardNumTF.text,@"cId",@"memberApp",@"remark", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(CardPackageInquiry) delegate:nil params:pram info:infoDic];
}


-(void)requestExchangeCard { //更改会员卡
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ExchangeCard object:nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ExchangeCard, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[[GlobalSetting shareGlobalSettingInstance] organizationID],@"oid",[[GlobalSetting shareGlobalSettingInstance] cId],@"cId",self.cardNumTF.text,@"newCId",self.codeTF.text,@"aCode",userID,@"mId", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(ExchangeCard) delegate:nil params:pram info:infoDic];
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
    
    if ([notification.name isEqualToString:CardPackageInquiry]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:CardPackageInquiry object:nil];
        
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        if ([responseObject[@"status"] boolValue]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alert.tag = 2000;
            [alert show];
            
        }
        else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
    
    if ([notification.name isEqualToString:ExchangeCard]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ExchangeCard object:nil];
        
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        if ([responseObject[@"status"] boolValue]) {
//            _networkConditionHUD.labelText = responseObject [MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            [[GlobalSetting shareGlobalSettingInstance] setcId:self.cardNumTF.text];
            
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
