//
//  ScanResultViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "ScanResultViewController.h"
#import "NSString+Check.h"

@interface ScanResultViewController ()

@end

@implementation ScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"扫描结果";
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Right-arrow"] style:UIBarButtonItemStylePlain target:self action:@selector(back:)];//Title:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
//    self.navigationItem.leftBarButtonItem = item;
//    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, APP_WIDTH, APP_HEIGHT)];
    [webView sizeToFit];
    
    if ([NSString checkUrlWithString:_resultUrl]) {
        [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.resultUrl]]];
    } else {
        [webView loadHTMLString:[NSString stringWithFormat:@"<html><head><style>body{background-color:white;}</style></head><body>%@</body></html>", self.resultUrl] baseURL:nil];
    }
    [self.view addSubview:webView];
}

//-(void)back:(id)sender{
//    [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    if (controllers.count > 2) {
        NSRange range;
        range.location = 2;
        range.length = controllers.count - 2;
        
        [controllers removeObjectsInRange:range];
    }
    
    [self.navigationController setViewControllers:controllers];
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
