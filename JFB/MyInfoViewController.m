//
//  MyInfoViewController.m
//  JFB
//
//  Created by LYD on 15/8/20.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MyInfoViewController.h"
#import "MyInfoTableViewCell.h"
#import "AuthenticationViewController.h"
#import "ReceiveAddressViewController.h"
#import "ChangePWDViewController.h"
#import "MemberCardViewController.h"
#import "BindViewController.h"
#import "QRcodeViewController.h"

@interface MyInfoViewController () <UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSString *pensionStr;   //养老金额
}

@end

@implementation MyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"个人信息";
//    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *rightButn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButn.frame = CGRectMake(0, 0, 26, 26);
    rightButn.contentMode = UIViewContentModeScaleAspectFit;
    [rightButn setImage:[UIImage imageNamed:@"persion_qrcode"] forState:UIControlStateNormal];
    [rightButn addTarget:self action:@selector(rightBarButnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBarButn = [[UIBarButtonItem alloc] initWithCustomView:rightButn];
    self.navigationItem.rightBarButtonItem = rightBarButn;
    
    
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 55)];
    view.backgroundColor = [UIColor clearColor];
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [logoutBtn setFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 40)];
    [logoutBtn setBackgroundColor:RGBCOLOR(229, 24, 35)];
    logoutBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [logoutBtn setTitle:@"安全退出" forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logoutAction) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:logoutBtn];
    
    pensionStr = @"0.0";
    
    self.myTableView.tableFooterView = view;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"MyInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"MyInfoCell"];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.myTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self.myTableView reloadData];
    
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
    
    [self requestGetMemberInfo];    //发起用户信息请求
}

-(void)rightBarButnClick {
    QRcodeViewController *qrVC = [[QRcodeViewController alloc] init];
    NSString *phone = [NSString stringWithFormat:@"jfb-userid:%@",[[GlobalSetting shareGlobalSettingInstance] mMobile]];
    qrVC.qrString = phone;
    qrVC.titleStr = @"二维码名片";
    [self.navigationController pushViewController:qrVC animated:YES];
}

//设置Separator顶头
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.myTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.myTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.myTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.myTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyInfoTableViewCell *cell = (MyInfoTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MyInfoCell"];
    switch (indexPath.row) {
        case 0:
        {
            cell.imgView.image = [UIImage imageNamed:@"user_point"];
            NSString *mNameStr = [[GlobalSetting shareGlobalSettingInstance] mName];
            if ([mNameStr isEqualToString:@""]) {
                NSString *tel = [[[GlobalSetting shareGlobalSettingInstance] mMobile] stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                cell.textL.text = [NSString stringWithFormat:@"%@",tel];
            }
            else {
                cell.textL.text = mNameStr;
            }
            
            if ([[[GlobalSetting shareGlobalSettingInstance] authenticate] boolValue]) {
                cell.noticeL.textColor = Red_BtnColor;
                cell.noticeL.text = @"已实名认证";
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.accessoryIM.hidden = YES;
            }
            else {
                cell.noticeL.textColor = RGBCOLOR(150, 150, 150);
                cell.noticeL.text = @"未实名认证";
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.accessoryIM.hidden = NO;
            }
            
        }
            break;
            
        case 1:
        {
            cell.imgView.image = [UIImage imageNamed:@"user_admin_member_card"];
            cell.textL.text = @"会员卡";
            cell.noticeL.textColor = RGBCOLOR(150, 150, 150);
            BOOL ismBind = [[[GlobalSetting shareGlobalSettingInstance] mBinding] boolValue];
            BOOL canChange = [[[GlobalSetting shareGlobalSettingInstance] isChangeCard] boolValue];
            if (ismBind) {  //已绑定会员卡
                cell.noticeL.text = [NSString stringWithFormat:@"%@",[[GlobalSetting shareGlobalSettingInstance] cId]];
                if (canChange) {    //可修改
                    cell.accessoryIM.hidden = NO;
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                }
                else {
                    cell.accessoryIM.hidden = YES;
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
            }
            else {
                cell.noticeL.text = @"绑定实体卡";
                cell.accessoryIM.hidden = NO;
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            
        }
            break;
            
        case 2:
        {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.imgView.image = [UIImage imageNamed:@"user_account"];
            cell.textL.text = @"养老金";
            cell.noticeL.textColor = RGBCOLOR(255, 116, 0);
            cell.noticeL.text = [NSString stringWithFormat:@"%@元",pensionStr];
            cell.accessoryIM.hidden = YES;
        }
            break;
            
        case 3:
        {
            cell.imgView.image = [UIImage imageNamed:@"user_address"];
            cell.textL.text = @"收货地址";
            cell.noticeL.textColor = RGBCOLOR(53, 53, 53);
            cell.noticeL.text = @"添加/修改";
            cell.accessoryIM.hidden = NO;
        }
            break;
            
        case 4:
        {
            cell.imgView.image = [UIImage imageNamed:@"user_bind_phone"];
            if ([[[GlobalSetting shareGlobalSettingInstance] mBinding] boolValue]) { //已绑定
                if ([[[GlobalSetting shareGlobalSettingInstance] mMobile] length] == 11) {
                    NSString *tel = [[[GlobalSetting shareGlobalSettingInstance] mMobile] stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
                    cell.textL.text = [NSString stringWithFormat:@"绑定手机 %@",tel];
                }
                cell.noticeL.text = @"更改";
            }
            else { //未绑定
                cell.textL.text = @"";
                cell.noticeL.text = @"绑定";
            }
            
            cell.noticeL.textColor = RGBCOLOR(53, 53, 53);
            
            cell.accessoryIM.hidden = NO;
        }
            break;
            
        case 5:
        {
            cell.imgView.image = [UIImage imageNamed:@"user_password"];
            cell.textL.text = @"登录密码";
            cell.noticeL.textColor = RGBCOLOR(53, 53, 53);
            cell.noticeL.text = @"修改";
            cell.accessoryIM.hidden = NO;
        }
            break;
            
        default:
            break;
    }

    return cell;
    
}

//设置Separator顶头
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if ([[[GlobalSetting shareGlobalSettingInstance] authenticate] boolValue]) {    //已认证
            AuthenticationViewController *authenticationVC = [[AuthenticationViewController alloc] init];
            authenticationVC.isAuthenticated = YES;
            authenticationVC.titleStr = @"修改邮箱";
            [self.navigationController pushViewController:authenticationVC animated:YES];
        }
        else {
            AuthenticationViewController *authenticationVC = [[AuthenticationViewController alloc] init];
            authenticationVC.isAuthenticated = NO;
            authenticationVC.titleStr = @"实名认证";
            [self.navigationController pushViewController:authenticationVC animated:YES];
        }
    }
    else if (indexPath.row == 1) {
        
        BOOL ismBind = [[[GlobalSetting shareGlobalSettingInstance] mBinding] boolValue];
        BOOL canChange = [[[GlobalSetting shareGlobalSettingInstance] isChangeCard] boolValue];
        if (ismBind) {  //已绑定会员卡
            if (canChange) {    //可修改
                MemberCardViewController *cardVC = [[MemberCardViewController alloc] init];
                cardVC.isChangeCard = YES;
                cardVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:cardVC animated:YES];
            }
        }
        else {
            MemberCardViewController *cardVC = [[MemberCardViewController alloc] init];
            cardVC.isChangeCard = NO;
            cardVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:cardVC animated:YES];
        }
    }
    else if (indexPath.row == 3) {
        ReceiveAddressViewController *receiveVC = [[ReceiveAddressViewController alloc] init];
        receiveVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:receiveVC animated:YES];
    }
    else if (indexPath.row == 4) {
        BindViewController *bindVC = [[BindViewController alloc] init];
        bindVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:bindVC animated:YES];
    }
    else if (indexPath.row == 5) {
        ChangePWDViewController *changeVC = [[ChangePWDViewController alloc] init];
        changeVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:changeVC animated:YES];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)logoutAction {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您确定要退出登录积分宝吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag = 4040;
    [alert show];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 4040) {
        if (buttonIndex == 1) {
            [[GlobalSetting shareGlobalSettingInstance] logoutRemoveAllUserInfo];   //清空用户信息
            MBProgressHUD *mbpro = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            mbpro.mode = MBProgressHUDModeCustomView;
            UIImageView *imgV = [[UIImageView alloc] initWithImage:nil];
            mbpro.customView = imgV;
            mbpro.labelText = @"已退出登录";
            mbpro.animationType = MBProgressHUDAnimationFade;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                //        if ([responseObject[@"result"] isEqualToString:@"success"]) {
                [self.navigationController popViewControllerAnimated:YES];
                //        }
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        }
    }
}

#pragma mark - 发送请求
-(void)requestGetMemberInfo { //获取用户信息
    [_hud show:YES];

    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetMemberInfo object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetMemberInfo, @"op", nil];
    NSString *member_id = [[GlobalSetting shareGlobalSettingInstance] userID];    //用户ID
    if (member_id == nil) {
        member_id = @"";
    }
    
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:member_id,@"mId", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetMemberInfo) delegate:nil params:pram info:infoDic];
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
    
    if ([notification.name isEqualToString:GetMemberInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetMemberInfo object:nil];
        if ([responseObject[@"status"] boolValue]) {
            pensionStr = [NSString stringWithFormat:@"%@",responseObject[DATA][@"pension"]];
            [self.myTableView reloadData];
        }
        else {
            //            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            //            [alert show];
            
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
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
