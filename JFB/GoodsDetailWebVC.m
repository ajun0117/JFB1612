//
//  GoodsDetailWebVC.m
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "GoodsDetailWebVC.h"
#import "SubmitOrderViewController.h"

@interface GoodsDetailWebVC ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
}

@end

@implementation GoodsDetailWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"本单详情";
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
    
    self.priceL.text = [NSString stringWithFormat:@"%@元",self.goodsDic [@"sales_price"]];
    self.costPriceStrikeL.text = [NSString stringWithFormat:@"%@元",self.goodsDic [@"market_price"]];
    self.costPriceStrikeL.strikeThroughEnabled = YES;
    
    [_detailWebView setScalesPageToFit:YES];
    
    NSURL *url = [NSURL URLWithString:self.webUrlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:3600];
    [_detailWebView loadRequest:request];
    
}

- (IBAction)buyAction:(id)sender {
    SubmitOrderViewController *submitVC = [[SubmitOrderViewController alloc] init];
    submitVC.merchant_id = self.merchant_id;
    submitVC.goodsdataDic = self.goodsDic;
    [self.navigationController pushViewController:submitVC animated:YES];
}

#pragma mark - UIWeb Delegate
-(void)webViewDidStartLoad:(UIWebView *)webView {
    
    [_hud show:YES];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [_hud hide:YES];
    NSString *currentURL = [webView stringByEvaluatingJavaScriptFromString:@"document.location.href"];
    NSLog(@"currentURL  is  %@",currentURL);
//    NSString *title = [_detailWebView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    self.title = title;
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
