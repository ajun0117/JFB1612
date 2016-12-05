//
//  OrderRefundSuccessViewController.m
//  JFB
//
//  Created by LYD on 15/9/25.
//  Copyright © 2015年 李俊阳. All rights reserved.
//

#import "OrderRefundSuccessViewController.h"

@interface OrderRefundSuccessViewController ()

@end

@implementation OrderRefundSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"申请成功";
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    for (id controller in self.navigationController.viewControllers) {
        if ([NSStringFromClass([controller class]) isEqualToString:@"OrderRefundViewController"]) {
            [controllers removeObject:controller];
        }
    }
    [self.navigationController setViewControllers:controllers];
}

- (IBAction)backToOrderList:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
