//
//  MineViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/19.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MineViewController.h"
#import "MyInfoViewController.h"
#import "MyOrderViewController.h"
#import "MyPensionsViewController.h"
#import "MyEvaluateViewController.h"
#import "MyCollectionViewController.h"
#import "LoginViewController.h"
#import "ShopApplyViewController.h"
#import "RegisterViewController.h"
#import "WebViewController.h"

@interface MineViewController ()
{
    MBProgressHUD *_networkConditionHUD;
}

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent = NO;
    
    self.title = @"我的";
    
    self.headView = [[UIView alloc] init];
    self.headIM = [[UIImageView alloc] init];
    [self.headView addSubview:self.headIM];
    [self.view addSubview:self.headView];
    
    self.myTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    self.myTableView.dataSource = self;
    self.myTableView.delegate = self;
    [self.view addSubview:self.myTableView];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    BOOL isLogined = [[GlobalSetting shareGlobalSettingInstance] isLogined];
    
    if (isLogined) {
        self.navigationItem.rightBarButtonItem = nil;
        
        UIImage *loginImage = [UIImage imageNamed:@"bg_logined.jpg"];
        NSLog(@"loginImage.size: %@",NSStringFromCGSize(loginImage.size));
        self.headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, loginImage.size.height / loginImage.size.width * SCREEN_WIDTH);
        self.headIM.frame = CGRectMake(10, 10, SCREEN_WIDTH - 20, loginImage.size.height / loginImage.size.width * SCREEN_WIDTH - 20);
        self.headIM.image = loginImage;
        self.headIM.backgroundColor = [UIColor grayColor];
        NSLog(@"self.headIM.frame: %@",NSStringFromCGRect(self.headIM.frame));
        
        for (id subView in self.headView.subviews) {
            if ([subView isKindOfClass:[UIButton class]] || [subView isKindOfClass:[UILabel class]]) {
                [subView removeFromSuperview];
            }
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.headView) - 30, SCREEN_WIDTH, 21)];
        label.font = [UIFont systemFontOfSize:25];
        label.center = self.headIM.center;
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = NSTextAlignmentCenter;
        NSString *cidStr = [NSString stringWithFormat:@"%@",[[GlobalSetting shareGlobalSettingInstance] cId]];
        label.text = cidStr;
//        label.text = [[GlobalSetting shareGlobalSettingInstance] addSpacingToLabelWithString:cidStr];
        [self.headView addSubview:label];
        
    }
    else {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:@selector(toRegister)];
        
        UIImage *unLoginImage = [UIImage imageNamed:@"bg_unlogined.png"];
        NSLog(@"unLoginImage.size: %@",NSStringFromCGSize(unLoginImage.size));
        self.headView.frame = CGRectMake(0, 0, SCREEN_WIDTH, unLoginImage.size.height / unLoginImage.size.width * SCREEN_WIDTH);
        self.headIM.frame = CGRectMake(0, 0, SCREEN_WIDTH, unLoginImage.size.height / unLoginImage.size.width * SCREEN_WIDTH);
        self.headIM.image = unLoginImage;
        
        for (id subView in self.headView.subviews) {
            if ([subView isKindOfClass:[UIButton class]] || [subView isKindOfClass:[UILabel class]]) {
                [subView removeFromSuperview];
            }
        }
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake((self.headView.frame.size.width - 100) / 2, (self.headView.frame.size.height - 70) , 100, 20)];
        label.font = [UIFont systemFontOfSize:13];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"你还没登录~";
        [self.headView addSubview:label];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake((self.headView.frame.size.width - 80) / 2, (self.headView.frame.size.height - 50) , 80, 30);
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitleColor:Red_BtnColor forState:UIControlStateNormal];
        [button setTitle:@"登录" forState:UIControlStateNormal];
        button.layer.cornerRadius = 2;
        button.layer.borderColor = Red_BtnColor.CGColor;
        button.layer.borderWidth = 1;
        [button addTarget:self action:@selector(loginAction) forControlEvents:UIControlEventTouchUpInside];
        [self.headView addSubview:button];
    }
    NSLog(@"self.headView.frame: %@",NSStringFromCGRect(self.headView.frame));
    
    self.myTableView.frame =CGRectMake(0, VIEW_H(self.headView), SCREEN_WIDTH, SCREEN_HEIGHT - VIEW_H(self.headView) - 64 - 49);
//    self.myTableView.tableFooterView = [UIView new];
    
}


-(void)loginAction {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:loginVC animated:YES];
}

-(void)toRegister {
    RegisterViewController *registerVC = [[RegisterViewController alloc] init];
    registerVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:registerVC animated:YES];
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
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.row == 0) {
        cell.imageView.image = [UIImage imageNamed:@"user_point"];
        cell.textLabel.text = @"个人信息";
    }
    else if (indexPath.row == 1) {
        cell.imageView.image = [UIImage imageNamed:@"icon_order"];
        cell.textLabel.text = @"我的优惠劵";
    }
    else if (indexPath.row == 2) {
        cell.imageView.image = [UIImage imageNamed:@"icon_money"];
        cell.textLabel.text = @"我的消费收益";
    }
    else if (indexPath.row == 3) {
        cell.imageView.image = [UIImage imageNamed:@"icon_review"];
        cell.textLabel.text = @"我的评价";
    }
    else if (indexPath.row == 4) {
        cell.imageView.image = [UIImage imageNamed:@"icon_recommend"];
        cell.textLabel.text = @"我的收藏";
    }
//    else if (indexPath.row == 5) {
//        cell.imageView.image = [UIImage imageNamed:@"user_admin_member_card"];
//        cell.textLabel.text = @"我的钱包";
//    }
    else if (indexPath.row == 5) {
        cell.imageView.image = [UIImage imageNamed:@"ic_order_lottery_enable"];
        cell.textLabel.text = @"我的奖品";
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
    
    BOOL isLogined = [[GlobalSetting shareGlobalSettingInstance] isLogined];
    
    if (isLogined) {    //已登录
        if (indexPath.row == 0) {
            MyInfoViewController *infoVC = [[MyInfoViewController alloc] init];
            infoVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:infoVC animated:YES];
        }
        else if (indexPath.row == 1) {
            MyOrderViewController *orderVC = [[MyOrderViewController alloc] init];
            orderVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:orderVC animated:YES];
        }
        else if (indexPath.row == 2) {
            MyPensionsViewController *pensionsVC = [[MyPensionsViewController alloc] init];
            pensionsVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:pensionsVC animated:YES];
        }
        else if (indexPath.row == 3) {
            MyEvaluateViewController *evaluateVC = [[MyEvaluateViewController alloc] init];
            evaluateVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:evaluateVC animated:YES];
        }
        else if (indexPath.row == 4) {
            MyCollectionViewController *collectionVC = [[MyCollectionViewController alloc] init];
            collectionVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:collectionVC animated:YES];
        }
//        else if (indexPath.row == 5) {
//            if (!_networkConditionHUD) {
//                _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
//                [self.view addSubview:_networkConditionHUD];
//            }
//            _networkConditionHUD.labelText = @"功能暂未开通！";
//            _networkConditionHUD.mode = MBProgressHUDModeText;
//            _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
//            _networkConditionHUD.margin = HUDMargin;
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
//        }
        else if (indexPath.row == 5) {
            WebViewController *web = [[WebViewController alloc] init];
            NSString *preString = ActivityUrl(MyPrize);
            NSString *urlStr = [NSString stringWithFormat:@"%@?m=%@",preString,[[GlobalSetting shareGlobalSettingInstance] userID]];
            web.webUrlStr = urlStr;
            web.titleStr = @"我的奖品";
            web.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:web animated:YES];
        }
    }
    else {  //未登录
        if (!_networkConditionHUD) {
            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_networkConditionHUD];
        }
        _networkConditionHUD.labelText = @"请先登录";
        _networkConditionHUD.mode = MBProgressHUDModeText;
        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        _networkConditionHUD.margin = HUDMargin;
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
