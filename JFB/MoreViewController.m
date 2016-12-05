//
//  MoreViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/23.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MoreViewController.h"
#import "WebViewController.h"
#import "UMSocial.h"
#import "ShopApplyViewController.h"


@interface MoreViewController () <UMSocialUIDelegate>

@end

@implementation MoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"更多";
    
    self.myTableView.tableFooterView = [UIView new];
    
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
    return 4;
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
        cell.textLabel.text = @"关于积分宝";
    }
//    else if (indexPath.row == 1) {
//        cell.textLabel.text = @"支付帮助";
//    }
    else if (indexPath.row == 1) {
        cell.textLabel.text = @"APP分享";
    }
    else if (indexPath.row == 2) {
        cell.textLabel.text = @"商户申请";
    }
    else if (indexPath.row == 3) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"当前版本";
        
        UILabel *versionL = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 11, 80, 21)];
        versionL.textAlignment = NSTextAlignmentRight;
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        versionL.text = [NSString stringWithFormat:@"V %@",app_version];
        [cell addSubview:versionL];
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
        WebViewController *web = [[WebViewController alloc] init];
        web.webUrlStr = ActivityUrl(AboutUs);
        web.titleStr = @"关于积分宝";
        web.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:web animated:YES];
    }
//    else if (indexPath.row == 1) {
//        WebViewController *web = [[WebViewController alloc] init];
//        web.webUrlStr = ActivityUrl(PayHelp);
//        web.titleStr = @"支付帮助";
//        web.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:web animated:YES];
//    }
    else if (indexPath.row == 1) {
        //未安装时隐藏
        [UMSocialConfig hiddenNotInstallPlatforms:@[UMShareToQQ,UMShareToQzone,UMShareToWechatSession,UMShareToWechatTimeline]];
        
        //SDK4.2默认分享面板已经处理过是否隐藏
        [UMSocialSnsService presentSnsIconSheetView:self
                                             appKey:UM_Appkey
                                          shareText:@"积分宝平台http://3g.jfb315.com"
                                         shareImage:[UIImage imageNamed:@"app_icon.png"]
                                    shareToSnsNames:[NSArray arrayWithObjects:UMShareToWechatSession,UMShareToWechatTimeline,UMShareToQQ,UMShareToQzone, nil]
                                           delegate:self];
        
        [UMSocialData defaultData].extConfig.wechatSessionData.title = @"积分宝平台";
        [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://3g.jfb315.com/";
        //    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"积分宝平台";
        [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://3g.jfb315.com/";
        
        [UMSocialData defaultData].extConfig.qqData.title = @"积分宝平台";
        [UMSocialData defaultData].extConfig.qqData.url = @"http://3g.jfb315.com/";
        [UMSocialData defaultData].extConfig.qzoneData.title = @"积分宝平台";
        [UMSocialData defaultData].extConfig.qzoneData.url = @"http://3g.jfb315.com/";
    }
    else if (indexPath.row == 2) {
        ShopApplyViewController *applyVC = [[ShopApplyViewController alloc] init];
        applyVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:applyVC animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - 分享完成后的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
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
