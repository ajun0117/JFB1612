//
//  OrderDetailViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderDetailHeaderCell.h"
#import "OrderDetailInfoCell.h"
#import "ShopDetailGoodsCel.h"
#import "GoodsDetailShopInfoCell.h"
#import "DetailBottomNextCell.h"
#import "GoodsDetailWebVC.h"
#import "PayOrderViewController.h"
#import "SubmitOrderViewController.h"
#import "ShopMapNavigationViewController.h"
#import "OrderCouponCell.h"
#import "OrderRefundViewController.h"
#import "QRcodeViewController.h"
#import "ReplyViewController.h"
#import "GoodsDetailViewController.h"

#define InfoCell    @"orderDetailInfoCell"
#define HeaderCell      @"oderDetailHeaderCell"
#define GoodsCell    @"shopDetailGoodsCell"
#define ShopInfoCell      @"goodsDetailShopInfoCell"
#define BottomNextCell      @"detailBottomNextCell"
#define OrderCouCell      @"orderCouponCell"

@interface OrderDetailViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSDictionary *_goodsdataDic;
    NSDictionary *_orderdataDic;
    NSDictionary *_coupondataDic;
    UILabel *effective_dateL;   //代金券有效期
    UIButton *dobtn;    //代金券操作按钮
}
@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"订单详情";
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailGoodsCel" bundle:nil] forCellReuseIdentifier:GoodsCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"GoodsDetailShopInfoCell" bundle:nil] forCellReuseIdentifier:ShopInfoCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"OrderDetailHeaderCell" bundle:nil] forCellReuseIdentifier:HeaderCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"OrderDetailInfoCell" bundle:nil] forCellReuseIdentifier:InfoCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"DetailBottomNextCell" bundle:nil] forCellReuseIdentifier:BottomNextCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"OrderCouponCell" bundle:nil] forCellReuseIdentifier:OrderCouCell];

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
    
    [self requestGetOrderDetail];   //放在这里方便订单状态改变时，刷新界面
}

//-(void)toMapView {
//    ShopMapNavigationViewController *mapVC = [[ShopMapNavigationViewController alloc] init];
//    //    mapVC.latitudeStr = self.merchantdataDic [@"latitude"];
//    //    mapVC.longitudeStr = self.merchantdataDic [@"longitude"];
//    mapVC.shopDic = self.merchantdataDic;
//    [self.navigationController pushViewController:mapVC animated:YES];
//}

-(void)toTelPhone {
    NSString *phoneString = _goodsdataDic [@"mobile_number"];
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phoneString];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
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
    if (! [_coupondataDic isKindOfClass:[NSNull class]]) {  //显示券码信息并隐藏付款按钮
        return 5;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (! [_coupondataDic isKindOfClass:[NSNull class]]) {  //显示券码信息并隐藏付款按钮
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return [_coupondataDic [@"data"] count];
                break;
                
            case 2:
                return 1;
                break;
                
            case 3:
                return 2;
                break;
                
            case 4:
                return 1;
                break;
                
            default:
                break;
        }
        return 0;
    }
    else {
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return 1;
                break;
                
            case 2:
                return 2;
                break;
                
            case 3:
                return 1;
                break;
                
            default:
                break;
        }
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (! [_coupondataDic isKindOfClass:[NSNull class]]) {  //显示券码信息并隐藏付款按钮
        switch (indexPath.section) {
            case 0:
                return 126;
                break;
                
            case 1:
                return 50;
                break;
                
            case 2:
                return 80;
                break;
                
            case 3:  //图文详情
                if (indexPath.row == 0) {
                    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
                    NSLog(@"%f",cell.bounds.size.height);
                    return cell.bounds.size.height;
                }
                else if (indexPath.row == 1)  {
                    return 44;
                };
                break;
                
            case 4:
                return 220;
                break;
                
            default:
                break;
        }
        return 0;
    }
    else {
        switch (indexPath.section) {
            case 0:
                return 126;
                break;
                
            case 1:
                return 80;
                break;
                
            case 2:  //图文详情
                if (indexPath.row == 0) {
                    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
                    NSLog(@"%f",cell.bounds.size.height);
                    return cell.bounds.size.height;
                }
                else if (indexPath.row == 1)  {
                    return 44;
                };
                break;
                
            case 3:
                return 220;
                break;
                
            default:
                break;
        }
        return 0;
    }
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (! [_coupondataDic isKindOfClass:[NSNull class]]) {  //显示券码信息并隐藏付款按钮
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return 66;
                break;
                
            case 2:
                return 44;
                break;
                
            case 3:
                return 44;
                break;
                
            case 4:
                return 1;
                break;
                
            default:
                break;
        }
        return 0;
    }
    else {
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return 44;
                break;
                
            case 2:
                return 44;
                break;
                
            case 3:
                return 1;
                break;
                
            default:
                break;
        }
        return 0;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (! [_coupondataDic isKindOfClass:[NSNull class]]) {  //显示券码信息并隐藏付款按钮
        if ([_statusStr intValue] == 3 && [_is_appraisal intValue] == 0) {  //未消费
            return 60;
        }
        return 0;
    }
    else {
        if (section == 0) {
            return 60;    //上下留10像素边
        }
        return 0;
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (! [_coupondataDic isKindOfClass:[NSNull class]]) {  //显示券码信息并隐藏付款按钮
        switch (indexPath.section) {
            case 0: {
                OrderDetailHeaderCell *cell = (OrderDetailHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HeaderCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.goodsIM sd_setImageWithURL:[NSURL URLWithString:_goodsdataDic [@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                cell.goodsNameL.text = _goodsdataDic [@"goods_name"];
                cell.goodsIntroduceL.text = _goodsdataDic [@"goods_title"];
                if (! _goodsdataDic [@"sales_price"]) {
                    cell.priceL.text = @"";
                }
                else {
                    cell.priceL.text = [NSString stringWithFormat:@"%@",_goodsdataDic [@"sales_price"]];
                }
                return cell;
            }
                break;
                
                
            case 1: {
                OrderCouponCell *cell = (OrderCouponCell *)[tableView dequeueReusableCellWithIdentifier:OrderCouCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
//                cell.effective_dateL.text = _coupondataDic [@"effective_date"];
                NSDictionary *dic = _coupondataDic [@"data"] [indexPath.row];
                [cell.consume_codeBtn setTitle:dic[@"consume_code"] forState:UIControlStateNormal];
                [cell.consume_codeBtn addTarget:self action:@selector(qrCodeVC:) forControlEvents:UIControlEventTouchUpInside];
                cell.consume_codeBtn.tag = indexPath.row + 3000;
                int status = [dic [@"status"] intValue];
                switch (status) {
                    case 1:
                        cell.statusL.text = @"未消费";
                        cell.statusL.textColor = RGBCOLOR(85, 85, 85);
                        cell.consume_codeBtn.enabled = YES;
//                        [cell.dobtn setTitle:@"申请退款" forState:UIControlStateNormal];
//                        cell.dobtn.tag = indexPath.row + 2000;
//                        [cell.dobtn addTarget:self action:@selector(goRefund:) forControlEvents:UIControlEventTouchUpInside];
                        break;
                        
                    case 2:
                        cell.statusL.text = @"已消费";
                        cell.statusL.textColor = Red_BtnColor;
                        cell.consume_codeBtn.enabled = NO;
//                        cell.dobtn.hidden = YES;
                        break;
                        
                    case 3:
                        cell.statusL.text = @"待退款";
                        cell.statusL.textColor = RGBCOLOR(85, 85, 85);
                        cell.consume_codeBtn.enabled = NO;
//                        cell.dobtn.hidden = YES;
                        break;
                        
                    case 4:
                        cell.statusL.text = @"已退款";
                        cell.statusL.textColor = Red_BtnColor;
                        cell.consume_codeBtn.enabled = NO;
//                        cell.dobtn.hidden = YES;
                        break;
                        
                    default:
                        break;
                }

                return cell;
            }
                break;
                
            case 2: {
                GoodsDetailShopInfoCell *cell = (GoodsDetailShopInfoCell *)[tableView dequeueReusableCellWithIdentifier:ShopInfoCell];
                cell.shopsNameL.text = _goodsdataDic [@"merchant_name"];
                cell.shopAddressL.text = _goodsdataDic [@"address"];
                
                //            [cell.mapAddressBtn addTarget:self action:@selector(toMapView) forControlEvents:UIControlEventTouchUpInside];
                [cell.phoneBtn addTarget:self action:@selector(toTelPhone) forControlEvents:UIControlEventTouchUpInside];
                
                float dis = [_goodsdataDic [@"distance"] floatValue];
                float convertDis = 0;
                if (dis >= 1000) {
                    convertDis = dis / 1000;
                    cell.distanceL.text = [NSString stringWithFormat:@"%.1fkm",convertDis];
                }
                else {
                    cell.distanceL.text = [NSString stringWithFormat:@"%.1fm",dis];
                }
                return cell;
            }
                break;
                
            case 3: {
                if (indexPath.row == 0) {
                    ShopDetailGoodsCel *cell = (ShopDetailGoodsCel *)[tableView dequeueReusableCellWithIdentifier:GoodsCell];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    NSString *merchant_info = _goodsdataDic [@"merchant_info"];
                    if ([merchant_info isKindOfClass:[NSNull class]]) {
                        cell.emptyL.hidden = NO;
                        cell.contentL.hidden = YES;
                    }
                    else {
                        cell.emptyL.hidden = YES;
                        cell.contentL.hidden = NO;
                        cell.contentL.text = merchant_info;
                    }
                    [cell.contentL sizeToFit];
                    CGRect rect = cell.bounds;
                    rect.size.height = 8 + cell.contentL.bounds.size.height + 8 + 21;
                    cell.bounds = rect;
                    
                    return cell;
                }
                else if (indexPath.row == 1) {
                    DetailBottomNextCell *cell = (DetailBottomNextCell *)[tableView dequeueReusableCellWithIdentifier:BottomNextCell];
                    cell.nextNoticeL.text = @"查看图文详情";
                    return cell;
                }
            }
                break;
                
            case 4: {
                
                OrderDetailInfoCell *cell = (OrderDetailInfoCell *)[tableView dequeueReusableCellWithIdentifier:InfoCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.orderNumberL.text = [NSString stringWithFormat:@"%@",_orderdataDic [@"order_no"]];
                cell.phoneL.text = [NSString stringWithFormat:@"%@",_orderdataDic [@"mobile"]];
                cell.orderTimeL.text = _orderdataDic [@"time"];
                cell.numberL.text = [NSString stringWithFormat:@"%@",_orderdataDic [@"qty"]];
                cell.allPriceL.text = [NSString stringWithFormat:@"%@元",_orderdataDic [@"order_amount"]];
                
                return cell;
            }
                break;
                
            default:
                break;
        }
        
        
        return nil;
    }
    else {
        switch (indexPath.section) {
            case 0: {
                OrderDetailHeaderCell *cell = (OrderDetailHeaderCell *)[tableView dequeueReusableCellWithIdentifier:HeaderCell];
                [cell.goodsIM sd_setImageWithURL:[NSURL URLWithString:_goodsdataDic [@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                cell.goodsNameL.text = _goodsdataDic [@"goods_name"];
                cell.goodsIntroduceL.text = _goodsdataDic [@"goods_title"];
                if (! _goodsdataDic [@"sales_price"]) {
                    cell.priceL.text = @"";
                }
                else {
                    cell.priceL.text = [NSString stringWithFormat:@"%@",_goodsdataDic [@"sales_price"]];
                }
                return cell;
            }
                break;
                
            case 1: {
                GoodsDetailShopInfoCell *cell = (GoodsDetailShopInfoCell *)[tableView dequeueReusableCellWithIdentifier:ShopInfoCell];
                cell.shopsNameL.text = _goodsdataDic [@"merchant_name"];
                cell.shopAddressL.text = _goodsdataDic [@"address"];
                
                //            [cell.mapAddressBtn addTarget:self action:@selector(toMapView) forControlEvents:UIControlEventTouchUpInside];
                [cell.phoneBtn addTarget:self action:@selector(toTelPhone) forControlEvents:UIControlEventTouchUpInside];
                
                float dis = [_goodsdataDic [@"distance"] floatValue];
                float convertDis = 0;
                if (dis >= 1000) {
                    convertDis = dis / 1000;
                    cell.distanceL.text = [NSString stringWithFormat:@"%.1fkm",convertDis];
                }
                else {
                    cell.distanceL.text = [NSString stringWithFormat:@"%.1fm",dis];
                }
                return cell;
            }
                break;
                
            case 2: {
                if (indexPath.row == 0) {
                    ShopDetailGoodsCel *cell = (ShopDetailGoodsCel *)[tableView dequeueReusableCellWithIdentifier:GoodsCell];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    NSString *merchant_info = _goodsdataDic [@"merchant_info"];
                    if ([merchant_info isKindOfClass:[NSNull class]]) {
                        cell.emptyL.hidden = NO;
                        cell.contentL.hidden = YES;
                    }
                    else {
                        cell.emptyL.hidden = YES;
                        cell.contentL.hidden = NO;
                        cell.contentL.text = merchant_info;
                    }
                    [cell.contentL sizeToFit];
                    CGRect rect = cell.bounds;
                    rect.size.height = 8 + cell.contentL.bounds.size.height + 8 + 21;
                    cell.bounds = rect;
                    
                    return cell;
                }
                else if (indexPath.row == 1) {
                    DetailBottomNextCell *cell = (DetailBottomNextCell *)[tableView dequeueReusableCellWithIdentifier:BottomNextCell];
                    cell.nextNoticeL.text = @"查看图文详情";
                    return cell;
                }
            }
                break;
                
            case 3: {
                
                OrderDetailInfoCell *cell = (OrderDetailInfoCell *)[tableView dequeueReusableCellWithIdentifier:InfoCell];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                cell.orderNumberL.text = [NSString stringWithFormat:@"%@",_orderdataDic [@"order_no"]];
                cell.phoneL.text = [NSString stringWithFormat:@"%@",_orderdataDic [@"mobile"]];
                cell.orderTimeL.text = _orderdataDic [@"time"];
                cell.numberL.text = [NSString stringWithFormat:@"%@",_orderdataDic [@"qty"]];
                cell.allPriceL.text = [NSString stringWithFormat:@"%@元",_orderdataDic [@"order_amount"]];
                
                return cell;
            }
                break;
                
            default:
                break;
        }
        
        
        return nil;
    }
    
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (! [_coupondataDic isKindOfClass:[NSNull class]]) {  //显示券码信息并隐藏付款按钮
        switch (section) {
            case 0:
                return nil;
                break;
                
            case 1: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 66)];
                headView.backgroundColor = [UIColor whiteColor];
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, SCREEN_WIDTH - 16, 21)];
                noticeL.textColor = [UIColor darkGrayColor];
                noticeL.font = [UIFont systemFontOfSize:15];
                noticeL.text = @"代金券";
                [headView addSubview:noticeL];
                
                UILabel *noticeDateL = [[UILabel alloc] initWithFrame:CGRectMake(8, 37, 70, 21)];
                noticeDateL.textColor = [UIColor darkGrayColor];
                noticeDateL.font = [UIFont systemFontOfSize:15];
                noticeDateL.text = @"有效期至:";
                [headView addSubview:noticeDateL];
                
                effective_dateL = [[UILabel alloc] initWithFrame:CGRectMake(86, 37, 90, 21)];
                effective_dateL.textColor = [UIColor darkGrayColor];
                effective_dateL.font = [UIFont systemFontOfSize:15];
                [headView addSubview:effective_dateL];
                
                dobtn = [UIButton buttonWithType:UIButtonTypeCustom];
                dobtn.frame = CGRectMake(222, 32, 90, 30);
                dobtn.titleLabel.font = [UIFont systemFontOfSize:15];
                dobtn.backgroundColor = Red_BtnColor;
                [dobtn setTitle:@"申请退款" forState:UIControlStateNormal];
                dobtn.hidden = YES;
                [dobtn addTarget:self action:@selector(goRefund:) forControlEvents:UIControlEventTouchUpInside];
                [headView addSubview:dobtn];
                
                effective_dateL.text = _coupondataDic [@"effective_date"];
                
//                statusStr = @"2";  //未消费
//                is_appraisal = @"-1";
//                
//                statusStr = @"3";  //已消费
//                is_appraisal = @"0";    //未评论
                
                if ([_statusStr intValue] == 2 && [_is_appraisal intValue] == -1) {  //未消费
                    dobtn.hidden = NO;
                }
                else {
                    dobtn.hidden = YES;
                }
                
                return headView;
            }
                break;
                
            case 2: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"商家信息";
                [headView addSubview:noticeL];
                return headView;
            }
                break;
                
            case 3: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"购买须知";
                [headView addSubview:noticeL];
                return headView;
            }
                break;
                
            case 4: {
                return nil;
            }
                break;
                
            default:
                break;
        }
        return nil;
        
    }
    else {
        switch (section) {
            case 0:
                return nil;
                break;
                
            case 1: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"商家信息";
                [headView addSubview:noticeL];
                return headView;
            }
                break;
                
            case 2: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"购买须知";
                [headView addSubview:noticeL];
                return headView;
            }
                break;
                
            case 3: {
                return nil;
            }
                break;
                
            default:
                break;
        }
        return nil;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (! [_coupondataDic isKindOfClass:[NSNull class]]) {  //显示券码信息并隐藏付款按钮
        if (section == 0) {
            if ([_statusStr intValue] == 3 && [_is_appraisal intValue] == 0) {  //已消费未评价
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
                headView.backgroundColor = [UIColor clearColor];

                UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                payBtn.frame = CGRectMake(8, 10, SCREEN_WIDTH - 16, 40);
                [payBtn setTitle:@"评价" forState:UIControlStateNormal];
                payBtn.titleLabel.font = [UIFont systemFontOfSize:15];
                payBtn.backgroundColor = RGBCOLOR(229, 24, 35);
                [payBtn addTarget:self action:@selector(evaluateAction) forControlEvents:UIControlEventTouchUpInside];
                [headView addSubview:payBtn];
                
                return headView;
            }
            return nil;
        }
    }
    else {
        if (section == 0) {
            UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
            headView.backgroundColor = [UIColor clearColor];

            UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            payBtn.frame = CGRectMake(8, 10, SCREEN_WIDTH - 16, 40);
            [payBtn setTitle:@"付款" forState:UIControlStateNormal];
            payBtn.titleLabel.font = [UIFont systemFontOfSize:15];
            payBtn.backgroundColor = RGBCOLOR(229, 24, 35);
            [payBtn addTarget:self action:@selector(payAction) forControlEvents:UIControlEventTouchUpInside];
            [headView addSubview:payBtn];
            
            return headView;
        }
        return nil;
    }
    return nil;
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
    
    if (! [_coupondataDic isKindOfClass:[NSNull class]]) {  //显示券码信息并隐藏付款按钮
        if (indexPath.section == 0) {
            GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
            detailVC.goods_id = _goodsdataDic [@"goods_id"];
            detailVC.merchant_id = _goodsdataDic [@"merchant_id"];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        
        else if (indexPath.section == 3) {
            if (indexPath.row == 1) {
                GoodsDetailWebVC *detailWebVC = [[GoodsDetailWebVC alloc] init];
                detailWebVC.webUrlStr = _goodsdataDic [@"graphic_details_url"];
                detailWebVC.goodsDic = _goodsdataDic;
                detailWebVC.merchant_id = _goodsdataDic [@"merchant_id"];
                [self.navigationController pushViewController:detailWebVC animated:YES];
            }
        }
    }
    else {
        if (indexPath.section == 0) {
            GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
            detailVC.goods_id = _goodsdataDic [@"goods_id"];
            detailVC.merchant_id = _goodsdataDic [@"merchant_id"];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        
        else if (indexPath.section == 2) {
            if (indexPath.row == 1) {
                GoodsDetailWebVC *detailWebVC = [[GoodsDetailWebVC alloc] init];
                detailWebVC.webUrlStr = _goodsdataDic [@"graphic_details_url"];
                detailWebVC.goodsDic = _goodsdataDic;
                detailWebVC.merchant_id = _goodsdataDic [@"merchant_id"];
                [self.navigationController pushViewController:detailWebVC animated:YES];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - button Actions

-(void)payAction {
    //付款
//    PayOrderViewController *payVC = [[PayOrderViewController alloc] init];
//    [self.navigationController pushViewController:payVC animated:YES];
    SubmitOrderViewController *submitVC = [[SubmitOrderViewController alloc] init];
    submitVC.merchant_id = _goodsdataDic [@"merchant_id"];
    submitVC.goodsdataDic = _goodsdataDic;
    submitVC.order_no = self.order_no;
    [self.navigationController pushViewController:submitVC animated:YES];
}

-(void)goRefund:(UIButton *)sender {
//    int row = (int)sender.tag - 2000;
//    NSDictionary *dic = _coupondataDic [@"data"] [row];
//    NSString *coupon_no = [NSString stringWithFormat:@"%@",dic[@"coupon_no"]];
    OrderRefundViewController *refundVC = [[OrderRefundViewController alloc] init];
//    refundVC.coupon_no = coupon_no;
    refundVC.order_no = self.order_no;
    refundVC.refund_amount = _orderdataDic [@"real_amount"];
    refundVC.goodsDic = _goodsdataDic;
    NSMutableArray *couMutableAry = [[NSMutableArray alloc] init];
    for (NSDictionary *dic in _coupondataDic [@"data"]) {
        int staInt = [dic [@"status"] intValue];
        if (staInt == 1) {  //未使用，只有未使用的券才能退款
            [couMutableAry addObject:dic];
        }
    }
    refundVC.couponArray = couMutableAry;   //传给退款页面的券码数组都是“未使用”状态的券码
    [self.navigationController pushViewController:refundVC animated:YES];
}

-(void)qrCodeVC:(UIButton *)sender {
    int row = (int)sender.tag - 3000;
    NSDictionary *dic = _coupondataDic [@"data"] [row];
    
    QRcodeViewController *qrVC = [[QRcodeViewController alloc] init];
    NSString *phone = [NSString stringWithFormat:@"jfb-voucher:%@",dic[@"consume_code"]];
    qrVC.qrString = phone;
    qrVC.titleStr = @"代金券";
    [self.navigationController pushViewController:qrVC animated:YES];
}

-(void)evaluateAction {
    //评价
    ReplyViewController *replyViewVC = [[ReplyViewController alloc]init];
    replyViewVC.merchant_id = _goodsdataDic [@"merchant_id"];
    replyViewVC.goods_id = _goodsdataDic [@"goods_id"];
    replyViewVC.order_no = self.order_no;
    [self.navigationController pushViewController:replyViewVC animated:YES];
}



#pragma mark - 发送请求
-(void)requestGetOrderDetail { //获取订单详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetOrderDetail object:nil];
    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetOrderDetail, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.their_type,@"type",self.order_no,@"order_no",userID,@"member_id",[locationDic objectForKey:@"latitude"],@"latitude",[locationDic objectForKey:@"longitude"],@"longitude", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetOrderDetail) delegate:nil params:pram info:infoDic];
}

#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        if (!_networkConditionHUD) {
            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_networkConditionHUD];
        }
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        _networkConditionHUD.mode = MBProgressHUDModeText;
        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        _networkConditionHUD.margin = HUDMargin;
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    
    if ([notification.name isEqualToString:GetOrderDetail]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetOrderDetail object:nil];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"获取商品详情" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
//        [alert show];
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
//            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            NSDictionary *dic = responseObject [DATA];
            _goodsdataDic = dic [@"goodsdata"];
            _orderdataDic = dic [@"orderdata"];
            _coupondataDic = dic [@"coupondata"];
            
            _statusStr = _orderdataDic [@"status"];
            _is_appraisal = _orderdataDic [@"is_appraisal"];
            
            [self.myTableView reloadData];
            
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
