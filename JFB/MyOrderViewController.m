//
//  MyOrderViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/23.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "MyOrderViewController.h"
#import "MyOrderTableViewCell.h"
#import "PayOrderViewController.h"
#import "SubmitOrderViewController.h"
#import "OrderDetailViewController.h"
#import "AJSegmentedControl.h"
#import "ReplyViewController.h"

@interface MyOrderViewController () <AJSegmentedControlDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *_orderArray;
    NSArray *_typesArray;   //类型数组
    NSString *statusStr; //订单状态类型
    NSString *is_appraisal; //是否评论
}

@end

@implementation MyOrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"我的优惠劵";
    
    NSDictionary *dic1 = @{@"type_name":@"全部"};
    NSDictionary *dic2 = @{@"type_name":@"未付款"};
    NSDictionary *dic3 = @{@"type_name":@"未消费"};
    NSDictionary *dic4 = @{@"type_name":@"待评价"};
    NSDictionary *dic5 = @{@"type_name":@"已退款"};
    _typesArray = @[dic1, dic2, dic3, dic4, dic5];
    [self createSegmentControlWithTitles:_typesArray];
    
    _orderArray = [[NSMutableArray alloc] init];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStylePlain target:self action:@selector(editTableCell)];
    
    self.myTableView.tableFooterView = [UIView new];
    [self.myTableView registerNib:[UINib nibWithNibName:@"MyOrderTableViewCell" bundle:nil] forCellReuseIdentifier:@"MyOrderCell"];
    
    statusStr = @"-1";  //全部
    is_appraisal = @"-1";
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
    
    [self requestGetOrderList];
}

#pragma mark - 自定义segmented
- (void)createSegmentControlWithTitles:(NSArray *)titls
{
    AJSegmentedControl *mySegmentedControl = [[AJSegmentedControl alloc] initWithOriginY:0 Titles:titls delegate:self];
    [self.view addSubview:mySegmentedControl];
}


- (void)ajSegmentedControlSelectAtIndex:(NSInteger)index
{
    NSLog(@"%ld",(long)index);
    switch (index) {
        case 0:
            statusStr = @"-1";  //全部
            is_appraisal = @"-1";
            break;
            
        case 1:
            statusStr = @"1";  //未付款
            is_appraisal = @"-1";
            break;
            
        case 2:
            statusStr = @"2";  //未消费
            is_appraisal = @"-1";
            break;
            
        case 3:
            statusStr = @"3";  //已消费
            is_appraisal = @"0";    //未评论
            break;
            
        case 4:
            statusStr = @"4";  //已退款
            is_appraisal = @"-1";
            break;
            
        default:
            break;
    }
    
    [self requestGetOrderList];
}


-(void)editTableCell {
    if ([self.navigationItem.rightBarButtonItem.title isEqualToString:@"编辑"]) {
        
        _networkConditionHUD.labelText = @"未消费订单和已退款订单不能删除！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:2];
        
        self.myTableView.editing = YES;
        [self.navigationItem.rightBarButtonItem setTitle:@"完成"];
        return;
    }
    
    self.myTableView.editing = NO;
    [self.navigationItem.rightBarButtonItem setTitle:@"编辑"];
    
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
    return [_orderArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dic = _orderArray [indexPath.row];
    MyOrderTableViewCell *cell = (MyOrderTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"MyOrderCell"];
    [cell.orderIM sd_setImageWithURL:[NSURL URLWithString:dic[@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
    cell.goodsNameL.text = dic [@"goods_name"];
    cell.priceL.text = [NSString stringWithFormat:@"%@元",dic [@"order_amount"]];
    cell.numberL.text = [NSString stringWithFormat:@"X%@",dic [@"qty"]];
    int status = [dic [@"status"] intValue];
    NSString *statusString;
    switch (status) {
        case 1: {
            cell.payBtn.hidden = NO;
            [cell.payBtn setTitle:@"付款" forState:UIControlStateNormal];
            statusString = @"未付款";
        }
            break;
            
        case 2: {
            cell.payBtn.hidden = YES;
            statusString = @"未消费";
        }
            break;
            
        case 3:
            if ([dic [@"is_appraisal"] intValue] == 0) {
                statusString = @"未评价";
                cell.payBtn.hidden = NO;
                [cell.payBtn setTitle:@"评价" forState:UIControlStateNormal];
            }
            else if ([dic [@"is_appraisal"] intValue] == 1) {
                statusString = @"已评价";
                cell.payBtn.hidden = YES;
            }
            break;
            
        case 4: {
            cell.payBtn.hidden = YES;
            statusString = @"已退款";
        }
            break;
            
        case 5: {
            cell.payBtn.hidden = YES;
            statusString = @"已删除";
        }
            break;
            
        default:
            break;
    }
    cell.statusL.text = statusString;
    cell.payBtn.tag = indexPath.row + 1000;
    [cell.payBtn addTarget:self action:@selector(payAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([statusStr isEqualToString:@"2"] || [statusStr isEqualToString:@"4"]) {
        return NO;
    }
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *dic = _orderArray [indexPath.row];
        [self DeleteOrderWithOrderNo:dic [@"order_no"]];
        [_orderArray removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }
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
    NSDictionary *dic = _orderArray [indexPath.row];
    OrderDetailViewController *detailVC = [[OrderDetailViewController alloc] init];
    detailVC.order_no = dic [@"order_no"];
    detailVC.their_type = dic [@"their_type"];
    detailVC.statusStr = statusStr;
    detailVC.is_appraisal = is_appraisal; 
    [self.navigationController pushViewController:detailVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - button Actions
-(void)payAction:(UIButton *)btn {
//    PayOrderViewController *payVC = [[PayOrderViewController alloc] init];
//    [self.navigationController pushViewController:payVC animated:YES];
    
//    NSDictionary *dic = _orderArray [indexPath.row];
//    SubmitOrderViewController *submitVC = [[SubmitOrderViewController alloc] init];
//    submitVC.merchant_id = _goodsdataDic [@"merchant_id"];
//    submitVC.goodsdataDic = _goodsdataDic;
//    submitVC.order_no = self.order_no;
//    [self.navigationController pushViewController:submitVC animated:YES];
    
    int rowInt = (int)btn.tag - 1000;
    
    NSDictionary *dic = _orderArray [rowInt];
    
    if ([dic [@"is_appraisal"] intValue] == 0) {    //未评价
        ReplyViewController *replyViewVC = [[ReplyViewController alloc]init];
        replyViewVC.merchant_id = dic [@"merchant_id"];
        replyViewVC.goods_id = dic [@"goods_id"];
        replyViewVC.order_no = dic [@"order_no"];
        [self.navigationController pushViewController:replyViewVC animated:YES];
    }
    else if ([dic [@"status"] intValue] == 1) {
            SubmitOrderViewController *submitVC = [[SubmitOrderViewController alloc] init];
            submitVC.merchant_id = dic [@"merchant_id"];
            submitVC.order_no = dic [@"order_no"];
            NSDictionary *goodsDic = [NSDictionary dictionaryWithObjectsAndKeys:dic[@"goods_id"],@"goods_id",dic[@"goods_name"],@"goods_name",dic[@"mobile"],@"mobile",dic[@"order_amount"],@"order_amount",dic[@"qty"],@"qty",dic[@"sales_price"],@"sales_price",dic [@"their_type"],@"their_type", nil];
            submitVC.goodsdataDic = goodsDic;
            
            [self.navigationController pushViewController:submitVC animated:YES];
    }
}

#pragma mark - 发送请求
-(void)requestGetOrderList { //获取订单列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetOrderList object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetOrderList, @"op", nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userID,@"member_id",statusStr,@"status",is_appraisal,@"is_appraisal", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetOrderList) delegate:nil params:pram info:infoDic];
}

-(void)DeleteOrderWithOrderNo:(NSString *)orderNo { //删除订单
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:DeleteOrder object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:DeleteOrder, @"op", nil];
    //    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:userID,@"member_id",orderNo,@"order_no", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(DeleteOrder) delegate:nil params:pram info:infoDic];
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
    if ([notification.name isEqualToString:GetOrderList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetOrderList object:nil];
        
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        [_orderArray removeAllObjects];
        if ([responseObject[@"status"] boolValue]) {
            
            [_orderArray addObjectsFromArray:responseObject [DATA]];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        [self.myTableView reloadData];
    }
    
    if ([notification.name isEqualToString:DeleteOrder]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:DeleteOrder object:nil];
        
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
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
