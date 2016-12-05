//
//  WebViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/23.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "WebViewController.h"
#import "UMSocial.h"

@interface WebViewController () <UMSocialUIDelegate>
{
    __weak IBOutlet UIWebView *_webView;
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *items;
}

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = self.titleStr;
    [_webView setScalesPageToFit:YES];
    
    UIBarButtonItem *backButnItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Right-arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    items = [NSMutableArray arrayWithObjects:backButnItem, nil];
    self.navigationItem.leftBarButtonItems = items;
    
    if (self.canShare) {
         self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_action_share_white"] style:UIBarButtonItemStylePlain target:self action:@selector(shareClicked)];
    }
//    else {
//        self.navigationItem.rightBarButtonItem = nil;
//    }
    
    NSURL *url = [NSURL URLWithString:self.webUrlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
    [_webView loadRequest:request];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!_networkConditionHUD) {
        _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_networkConditionHUD];
    }
    _networkConditionHUD.mode = MBProgressHUDModeText;
    _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
    _networkConditionHUD.margin = HUDMargin;
}

-(void)back {
    NSLog(@"canGoBack : %d",[_webView canGoBack]);
    if ([_webView canGoBack]) {
        if ([items count] < 2) {
            UIBarButtonItem *closeButnItem = [[UIBarButtonItem alloc] initWithTitle:@"关闭" style:UIBarButtonItemStylePlain target:self action:@selector(close)];
            [items addObject:closeButnItem];
            self.navigationItem.leftBarButtonItems = items;
        }
        [_webView goBack];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)close {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UIWeb Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView {
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:_hud];
    }
    [_hud show:YES];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_hud hide:YES];
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    NSLog(@"currentURL  is  %@",currentURL);
    NSString *title = [_webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    self.title = title;
}

-(void)shareClicked {
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

#pragma mark - 分享完成后的回调
-(void)didFinishGetUMSocialDataInViewController:(UMSocialResponseEntity *)response
{
    //根据`responseCode`得到发送结果,如果分享成功
    if(response.responseCode == UMSResponseCodeSuccess)
    {
        [self requestModifyPoint];
        //得到分享到的微博平台名
        NSLog(@"share to sns name is %@",[[response.data allKeys] objectAtIndex:0]);
    }
}


#pragma mark - 发送请求
-(void)requestModifyPoint { //登录
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:ModifyPoint object:nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:ModifyPoint, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userID,@"mId",@"1",@"type", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(ModifyPoint) delegate:nil params:pram info:infoDic];
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
    
    if ([notification.name isEqualToString:ModifyPoint]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:ModifyPoint object:nil];
        if ([responseObject[@"status"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
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
