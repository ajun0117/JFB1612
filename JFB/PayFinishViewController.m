//
//  PayFinishViewController.m
//  JFB
//
//  Created by LYD on 15/9/23.
//  Copyright © 2015年 李俊阳. All rights reserved.
//

#import "PayFinishViewController.h"
#import "CouponTableViewCell.h"

#define CouponCell    @"couponTableViewCell"

@interface PayFinishViewController ()
{
    NSArray *couponAry;
}

@end

@implementation PayFinishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"支付结果";
    
    [self.couponTableView registerNib:[UINib nibWithNibName:@"CouponTableViewCell" bundle:nil] forCellReuseIdentifier:CouponCell];
    self.couponTableView.tableFooterView = [UIView new];
    
    self.orderNumberL.text = self.finishDic [@"orderdata"] [@"order_no"];
    self.goodsNameL.text = self.finishDic [@"goodsdata"] [@"goods_name"];
    couponAry = self.finishDic [@"coupondata"] [@"data"];
    self.couponNumL.text = [NSString stringWithFormat:@"(共%lu张)",(unsigned long)[couponAry count]];
}


//设置Separator顶头
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if ([self.couponTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.couponTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([self.couponTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.couponTableView setLayoutMargins:UIEdgeInsetsZero];
    }
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [couponAry count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CouponTableViewCell *cell = (CouponTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CouponCell];
    NSDictionary *dic = couponAry [indexPath.row];
    cell.couponNoL.text = [NSString stringWithFormat:@"代金券%ld",(long)indexPath.row + 1];
    cell.couponCodeL.text = [NSString stringWithFormat:@"%@",dic [@"consume_code"]];
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


- (IBAction)continueGoBuy:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSMutableArray *controllers = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
    for (id controller in self.navigationController.viewControllers) {
        if ([NSStringFromClass([controller class]) isEqualToString:@"PayOrderViewController"]) {
            [controllers removeObject:controller];
        }
    }
    [self.navigationController setViewControllers:controllers];
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
