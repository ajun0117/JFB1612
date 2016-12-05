//
//  GoodsDetailViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import "GoodsDetailHeadCell.h"
#import "GoodsDetailShopInfoCell.h"
#import "ShopDetailEvaluateCell.h"
#import "ShopDetailVoucherCell.h"
#import "DetailBottomNextCell.h"
#import "ShopDetailGoodsCel.h"
#import "ShopDetailGoodsCel.h"
#import "SubmitOrderViewController.h"
#import "GoodsDetailWebVC.h"
#import "WebViewController.h"
#import "AllEvaluateViewController.h"
#import "LoginViewController.h"

#define GoodsCell    @"shopDetailGoodsCell"
#define HeadCell      @"goodsDetailHeadCell"
#define ShopInfoCell      @"goodsDetailShopInfoCell"
#define EvaluateCell    @"shopDetailEvaluateCell"
#define VoucherCell    @"shopDetailVoucherCell"
#define BottomNextCell      @"detailBottomNextCell"


@interface GoodsDetailViewController () <UIAlertViewDelegate,UIWebViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSDictionary *_goodsdataDic;
    NSArray *_otherdataArray;
    NSString *_promise_urlStr;
    NSArray *_recommenddataArray;
    NSDictionary *_reviewdataDic;
    
    NSString *flagStr; //收藏1，取消收藏2
    
    BOOL isWebViewFirstLoad;    //cell的webView第一次加载
    
    CGFloat webViewHeight;  //商品详情cell中webView的高度
}

@end

@implementation GoodsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商品详情";
    
    UIButton *favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteBtn.frame = CGRectMake(0, 0, 24, 24);
    favoriteBtn.contentMode = UIViewContentModeScaleAspectFit;
    [favoriteBtn setImage:[UIImage imageNamed:@"ic_action_favorite_off_white"] forState:UIControlStateNormal];
    [favoriteBtn setImage:[UIImage imageNamed:@"ic_action_favorite_on"] forState:UIControlStateSelected];
    [favoriteBtn addTarget:self action:@selector(toFavorite:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *favoriteBarBtn = [[UIBarButtonItem alloc] initWithCustomView:favoriteBtn];
    self.navigationItem.rightBarButtonItem = favoriteBarBtn;
    
    webViewHeight = 83.0f;
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"GoodsDetailHeadCell" bundle:nil] forCellReuseIdentifier:HeadCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"GoodsDetailShopInfoCell" bundle:nil] forCellReuseIdentifier:ShopInfoCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"DetailBottomNextCell" bundle:nil] forCellReuseIdentifier:BottomNextCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailEvaluateCell" bundle:nil] forCellReuseIdentifier:EvaluateCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailVoucherCell" bundle:nil] forCellReuseIdentifier:VoucherCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailGoodsCel" bundle:nil] forCellReuseIdentifier:GoodsCell];
    
    isWebViewFirstLoad = YES;
    
    [self requestGetGoodsDetail];
    
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

//-(void)toMapView {
//    ShopMapNavigationViewController *mapVC = [[ShopMapNavigationViewController alloc] init];
//    //    mapVC.latitudeStr = self.merchantdataDic [@"latitude"];
//    //    mapVC.longitudeStr = self.merchantdataDic [@"longitude"];
//    mapVC.shopDic = self.merchantdataDic;
//    [self.navigationController pushViewController:mapVC animated:YES];
//}

-(void)toTelPhone {
    NSString *phoneString = _goodsdataDic [@"tel"];
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phoneString];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
}

-(void)toFavorite:(UIButton *)btn {
    BOOL isLogined = [[GlobalSetting shareGlobalSettingInstance] isLogined];
    if (! isLogined) {
        NSLog(@"未登录");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有登录，现在登录吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 4040;
        [alert show];
        return;
    }
    if (btn.selected) {
        flagStr = @"2"; //取消
    }
    else {
        flagStr = @"1";
    }
    
    [self requestCollectSubmit];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (! [_reviewdataDic isKindOfClass:[NSNull class]]) {
        return 6;
    }
    else {
        return 5;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (! [_reviewdataDic isKindOfClass:[NSNull class]]) {  //有评价
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return 1;
                break;
                
            case 2:     //图文详情
                return 2;
                break;
                
            case 3:
                return 2;
                break;
                
            case 4:     //商家的其他商品列表
                return [_recommenddataArray count]>0 ? [_recommenddataArray count]:1;  //后续要改为数组个数
                break;
                
            case 5:     //用户还看了的商品列表
                return [_otherdataArray count]>0 ? [_otherdataArray count]:1;  //后续要改为数组个数
                break;
                
            default:
                break;
        }
        return 0;
    }
    else {      //无评价
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return 1;
                break;
                
            case 2:     //图文详情
                return 2;
                break;
                
            case 3:     //商家的其他商品列表
                return [_recommenddataArray count]>0 ? [_recommenddataArray count]:1;  //后续要改为数组个数
                break;
                
            case 4:     //用户还看了的商品列表
                return [_otherdataArray count]>0 ? [_otherdataArray count]:1;  //后续要改为数组个数
                break;
                
            default:
                break;
        }
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (! [_reviewdataDic isKindOfClass:[NSNull class]]) {  //有评价
        switch (indexPath.section) {
            case 0:
                return 285;
                break;
                
            case 1:
                return 80;
                break;
                
            case 2:  //图文详情
                if (indexPath.row == 0) {
//                    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//                    NSLog(@"cell.bounds.size.height: %f",cell.bounds.size.height);
//                    return cell.bounds.size.height;
                    return 8 + webViewHeight + 8 + 21;
                }
                else if (indexPath.row == 1)  {
                    return 44;
                };
                break;
                
            case 3:
                if (indexPath.row == 0) {
                    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//                    NSLog(@"%f",cell.bounds.size.height);
                    return cell.bounds.size.height;
                }
                else if (indexPath.row == 1)  {
                    return 44;
                };
                break;
                
            case 4: {   //商家的其他商品列表
                return 100;
            }
                break;
                
            case 5:     //用户还看了的商品列表
                return 100;
                break;
                
            default:
                break;
        }
        return 0;
    }
    else {  //无评价
        switch (indexPath.section) {
            case 0:
                return 285;
                break;
                
            case 1:
                return 80;
                break;
                
            case 2:  //图文详情
                if (indexPath.row == 0) {
//                    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//                    NSLog(@"cell.bounds.size.height: %f",cell.bounds.size.height);
//                    return cell.bounds.size.height;
                    return 8 + webViewHeight + 8 + 21;
                }
                else if (indexPath.row == 1)  {
                    return 44;
                };
                break;
                
            case 3: {   //商家的其他商品列表
                return 100;
            }
                break;
                
            case 4:     //用户还看了的商品列表
                return 100;
                break;
                
            default:
                break;
        }
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (! [_reviewdataDic isKindOfClass:[NSNull class]]) {  //有评价
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
                return 44;
                break;
                
            case 4:
                return 44;
                break;
                
            case 5:
                return 44;
                break;
                
            default:
                break;
        }
        return 0;
    }
    else {  //无评价
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
                return 44;
                break;
                
            case 4:
                return 44;
                break;
                
            default:
                break;
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (! [_reviewdataDic isKindOfClass:[NSNull class]]) {  //有评价
        switch (indexPath.section) {
            case 0: {
                GoodsDetailHeadCell *cell = (GoodsDetailHeadCell *)[tableView dequeueReusableCellWithIdentifier:HeadCell];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.bigIM sd_setImageWithURL:[NSURL URLWithString:_goodsdataDic [@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                cell.goodsNameL.text = _goodsdataDic [@"goods_name"];
                cell.goodsIntroduceL.text = _goodsdataDic [@"goods_title"];
                if (_goodsdataDic[@"sales_price"] != nil) {
                    cell.priceL.text = [NSString stringWithFormat:@"%@元",_goodsdataDic[@"sales_price"]];
                }
                if (_goodsdataDic[@"market_price"] != nil) {
                    cell.costPriceStrikeL.text = [NSString stringWithFormat:@"%@元",_goodsdataDic[@"market_price"]];
                }
                if (_goodsdataDic[@"sales"] != nil) {
                    cell.saleL.text = [NSString stringWithFormat:@"已售:%@",_goodsdataDic[@"sales"]];
                }
                [cell.buyBtn addTarget:self action:@selector(buyAction) forControlEvents:UIControlEventTouchUpInside];
                cell.buyBtn.layer.cornerRadius = 3;
                [cell.promiseBtn addTarget:self action:@selector(promiseAction) forControlEvents:UIControlEventTouchUpInside];
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
                    NSString *merchant_info = _goodsdataDic [@"zhaiyao"];
                    if ([merchant_info isKindOfClass:[NSNull class]]) {
                        cell.emptyL.hidden = NO;
                        cell.contentL.hidden = YES;
                        cell.contentWeb.hidden = YES;
                        cell.contentWeb.delegate = nil;
                    }
                    else {
                        cell.emptyL.hidden = YES;
                        cell.contentL.hidden = YES;
                        cell.contentWeb.hidden = NO;
                        cell.contentWeb.delegate = self;
                        cell.contentWeb.userInteractionEnabled = NO;
                        [cell.contentWeb loadHTMLString:merchant_info baseURL:nil];
                    }
//                    [cell.contentWeb sizeToFit];
//                    CGRect rect = cell.bounds;
//                    NSLog(@"cell.contentWeb.bounds.size.height: %f",cell.contentWeb.bounds.size.height);
//                    rect.size.height = 8 + cell.contentWeb.bounds.size.height + 8 + 21;
//                    cell.bounds = rect;
                    
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
                if (indexPath.row == 0) {
                    ShopDetailEvaluateCell *cell = (ShopDetailEvaluateCell *)[tableView dequeueReusableCellWithIdentifier:EvaluateCell];
                    NSDictionary *dic = _reviewdataDic [@"data"];
                    NSString *nickName = dic [@"nickname"];
                    cell.memberNameL.text = [[GlobalSetting shareGlobalSettingInstance] transformToStarStringWithString:nickName];
                    cell.timeL.text = dic [@"review_time"];
                    cell.rateView.rate = [dic [@"score"] floatValue];
                    cell.scoreL.text = [NSString stringWithFormat:@"%@分",dic [@"score"]];
                    cell.contentL.text = dic [@"content"];
                    [cell.contentL sizeToFit];
                    CGRect rect = cell.bounds;
                    rect.size.height = 8 + cell.memberNameL.bounds.size.height + 5 + cell.rateView.bounds.size.height + 5 + cell.contentL.bounds.size.height + 8 + 21;
                    cell.bounds = rect;
                    return cell;
                }
                else if (indexPath.row == 1) {
                    DetailBottomNextCell *cell = (DetailBottomNextCell *)[tableView dequeueReusableCellWithIdentifier:BottomNextCell];
                    cell.nextNoticeL.text = [NSString stringWithFormat:@"查看全部评论(%@)",_reviewdataDic [@"totalcount"]];
                    
                    return cell;
                }
            }
                break;
                
            case 4: {
                ShopDetailVoucherCell *cell = (ShopDetailVoucherCell *)[tableView dequeueReusableCellWithIdentifier:VoucherCell];
                
                if ([_recommenddataArray count] > 0) {
                    NSDictionary *dic = _recommenddataArray [indexPath.row];
                    cell.emptyL.hidden = YES;
                    cell.voucherView.hidden = NO;
                    [cell.voucherIM sd_setImageWithURL:[NSURL URLWithString:dic [@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                    cell.nameL.text = dic [@"goods_name"];
                    cell.priceL.text = [NSString stringWithFormat:@"%@元",dic[@"sales_price"]];
                    cell.costPriceStrikeL.text = [NSString stringWithFormat:@"%@元",dic[@"market_price"]];
                    cell.saleL.text = [NSString stringWithFormat:@"已售:%@",dic[@"sales"]];
                }
                else {
                    cell.emptyL.hidden = NO;
                    cell.voucherView.hidden = YES;
                }
    
                return cell;
            }
                break;
                
            case 5: {
                
                ShopDetailVoucherCell *cell = (ShopDetailVoucherCell *)[tableView dequeueReusableCellWithIdentifier:VoucherCell];
                
                if ([_otherdataArray count] > 0) {
                    NSDictionary *dic = _otherdataArray [indexPath.row];
                    cell.emptyL.hidden = YES;
                    cell.voucherView.hidden = NO;
                    [cell.voucherIM sd_setImageWithURL:[NSURL URLWithString:dic [@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                    cell.nameL.text = dic [@"goods_name"];
                    cell.priceL.text = [NSString stringWithFormat:@"%@元",dic[@"sales_price"]];
                    cell.costPriceStrikeL.text = [NSString stringWithFormat:@"%@元",dic[@"market_price"]];
                    cell.saleL.text = [NSString stringWithFormat:@"已售:%@",dic[@"sales"]];
                }
                else {
                    cell.emptyL.hidden = NO;
                    cell.voucherView.hidden = YES;
                }
                
                return cell;
            }
                break;
                
            default:
                break;
        }
        
        
        return nil;
    }
    else {  //无评价
        switch (indexPath.section) {
            case 0: {
                GoodsDetailHeadCell *cell = (GoodsDetailHeadCell *)[tableView dequeueReusableCellWithIdentifier:HeadCell];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.bigIM sd_setImageWithURL:[NSURL URLWithString:_goodsdataDic [@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                cell.goodsNameL.text = _goodsdataDic [@"goods_name"];
                cell.goodsIntroduceL.text = _goodsdataDic [@"goods_title"];
                cell.priceL.text = [NSString stringWithFormat:@"%@元",_goodsdataDic[@"sales_price"]];
                cell.costPriceStrikeL.text = [NSString stringWithFormat:@"%@元",_goodsdataDic[@"market_price"]];
                cell.saleL.text = [NSString stringWithFormat:@"已售:%@",_goodsdataDic[@"sales"]];
                [cell.buyBtn addTarget:self action:@selector(buyAction) forControlEvents:UIControlEventTouchUpInside];
                [cell.promiseBtn addTarget:self action:@selector(promiseAction) forControlEvents:UIControlEventTouchUpInside];
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
                    NSString *merchant_info = _goodsdataDic [@"zhaiyao"];
                    if ([merchant_info isKindOfClass:[NSNull class]]) {
                        cell.emptyL.hidden = NO;
                        cell.contentL.hidden = YES;
                        cell.contentWeb.hidden = YES;
                        cell.contentWeb.delegate = nil;
                    }
                    else {
                        cell.emptyL.hidden = YES;
                        cell.contentL.hidden = YES;
                        cell.contentWeb.hidden = NO;
                        cell.contentWeb.delegate = self;
                        cell.contentWeb.userInteractionEnabled = NO;
                        [cell.contentWeb loadHTMLString:merchant_info baseURL:nil];
                    }
                    
//                    [cell.contentWeb sizeToFit];
//                    CGRect rect = cell.bounds;
////                    NSLog(@"cell.contentWeb.scrollView.contentSize.height: %f",cell.contentWeb.scrollView.contentSize.height);
//                    rect.size.height = 8 + cell.contentWeb.scrollView.contentSize.height + 8 + 21;
//                    cell.bounds = rect;
                    
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
                ShopDetailVoucherCell *cell = (ShopDetailVoucherCell *)[tableView dequeueReusableCellWithIdentifier:VoucherCell];
                
                if ([_recommenddataArray count] > 0) {
                    NSDictionary *dic = _recommenddataArray [indexPath.row];
                    cell.emptyL.hidden = YES;
                    cell.voucherView.hidden = NO;
                    [cell.voucherIM sd_setImageWithURL:[NSURL URLWithString:dic [@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                    cell.nameL.text = dic [@"goods_name"];
                    cell.priceL.text = [NSString stringWithFormat:@"%@元",dic[@"sales_price"]];
                    cell.costPriceStrikeL.text = [NSString stringWithFormat:@"%@元",dic[@"market_price"]];
                    cell.saleL.text = [NSString stringWithFormat:@"已售:%@",dic[@"sales"]];
                }
                else {
                    cell.emptyL.hidden = NO;
                    cell.voucherView.hidden = YES;
                }
        
                return cell;
            }
                break;
                
            case 4: {
                ShopDetailVoucherCell *cell = (ShopDetailVoucherCell *)[tableView dequeueReusableCellWithIdentifier:VoucherCell];
        
                if ([_otherdataArray count] > 0) {
                    NSDictionary *dic = _otherdataArray [indexPath.row];
                    cell.emptyL.hidden = YES;
                    cell.voucherView.hidden = NO;
                    [cell.voucherIM sd_setImageWithURL:[NSURL URLWithString:dic [@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                    cell.nameL.text = dic [@"goods_name"];
                    cell.priceL.text = [NSString stringWithFormat:@"%@元",dic[@"sales_price"]];
                    cell.costPriceStrikeL.text = [NSString stringWithFormat:@"%@元",dic[@"market_price"]];
                    cell.saleL.text = [NSString stringWithFormat:@"已售:%@",dic[@"sales"]];
                }
                else {
                    cell.emptyL.hidden = NO;
                    cell.voucherView.hidden = YES;
                }
                
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
    if (! [_reviewdataDic isKindOfClass:[NSNull class]]) {  //有评价
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
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
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
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
                return headView;
            }
                break;
                
            case 3: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 40, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"评价";
                [headView addSubview:noticeL];
                
                DJQRateView *rateView = [[DJQRateView alloc] initWithFrame:CGRectMake(58, 12, 100, 20)];
                rateView.rate = [_goodsdataDic [@"score"] floatValue];
                [headView addSubview:rateView];
                
                UILabel *scoreL = [[UILabel alloc] initWithFrame:CGRectMake(166, 0, 80, 44)];
                scoreL.textColor = RGBCOLOR(255, 116, 0);
                scoreL.text = [NSString stringWithFormat:@"%@分",_goodsdataDic [@"score"]];
                [headView addSubview:scoreL];
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
                return headView;
            }
                break;
                
            case 4: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"商家的商品";
                [headView addSubview:noticeL];
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
                return headView;
            }
                break;
                
            case 5: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"小伙伴们还看了";
                [headView addSubview:noticeL];
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
                return headView;
            }
                break;
                
            default:
                break;
        }
        return nil;
    }
    else {  //无评价
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
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
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
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
                return headView;
            }
                break;
                
            case 3: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"商家的商品";
                [headView addSubview:noticeL];
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
                return headView;
            }
                break;
                
            case 4: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"小伙伴们还看了";
                [headView addSubview:noticeL];
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
                return headView;
            }
                break;
                
            default:
                break;
        }
        return nil;
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

    if (indexPath.section == 2) {
        if (indexPath.row == 1) {
            GoodsDetailWebVC *detailWebVC = [[GoodsDetailWebVC alloc] init];
            detailWebVC.webUrlStr = _goodsdataDic [@"graphic_details_url"];
            detailWebVC.goodsDic = _goodsdataDic;
            detailWebVC.merchant_id = self.merchant_id;
            [self.navigationController pushViewController:detailWebVC animated:YES];
        }
    }
    else if (indexPath.section == 3) {  //评价
        if (indexPath.row == 1) {
            //全部评价列表页
            AllEvaluateViewController *allVC = [[AllEvaluateViewController alloc] init];
            allVC.merchant_id =  self.merchant_id;
            allVC.goods_id = self.goods_id;
            [self.navigationController pushViewController:allVC animated:YES];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - button Actions
-(void)buyAction {
    BOOL isLogined = [[GlobalSetting shareGlobalSettingInstance] isLogined];
    if (! isLogined) {
//        _networkConditionHUD.labelText = @"请先登录！";
//        [_networkConditionHUD show:YES];
//        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"您还没有登录，现在登录吗？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        alert.tag = 5050;
        [alert show];
        return;
    }
    SubmitOrderViewController *submitVC = [[SubmitOrderViewController alloc] init];
    submitVC.merchant_id = self.merchant_id;
    submitVC.goodsdataDic = _goodsdataDic;
    [self.navigationController pushViewController:submitVC animated:YES];
}

-(void)promiseAction {
    WebViewController *webVC = [[WebViewController alloc] init];
    webVC.webUrlStr = _promise_urlStr;
    webVC.titleStr = @"积分宝承诺";
    [self.navigationController pushViewController:webVC animated:YES];
}

#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 4040 || alertView.tag == 5050) {
        if (buttonIndex == 1) {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:loginVC animated:YES];
        }
    }
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    if (isWebViewFirstLoad && _goodsdataDic [@"zhaiyao"]) {
        isWebViewFirstLoad = NO;
//        CGFloat height = [[webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
        webViewHeight = webView.scrollView.contentSize.height;
        NSLog(@"webViewHeight: %f",webViewHeight);
//        CGRect frame = webView.frame;
//        webView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, webViewHeight);
        
        [self.myTableView reloadData];
    }
}

#pragma mark - 发送请求
-(void)requestGetGoodsDetail { //获取商户详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetGoodsDetail object:nil];
    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetGoodsDetail, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.goods_id,@"goods_id",self.merchant_id,@"merchant_id",userID,@"member_id",[locationDic objectForKey:@"latitude"],@"latitude",[locationDic objectForKey:@"longitude"],@"longitude", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetGoodsDetail) delegate:nil params:pram info:infoDic];
}

-(void)requestCollectSubmit { //收藏或取消收藏
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:SubmitCollect object:nil];
    //    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:SubmitCollect, @"op", nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    //    @"collect_type":@"0" //商品收藏
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.goods_id,@"collect_id",@"0",@"collect_type",userID,@"member_id",flagStr,@"flag", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(SubmitCollect) delegate:nil params:pram info:infoDic];
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
    
    if ([notification.name isEqualToString:GetGoodsDetail]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetGoodsDetail object:nil];
        if ([responseObject[@"status"] boolValue]) {
            NSLog(@"GetMerchantList_responseObject: %@",responseObject);
            
            NSDictionary *dic = responseObject [DATA];
            _goodsdataDic = dic [@"goodsdata"];
            _otherdataArray = dic [@"otherdata"];
            _promise_urlStr = dic [@"promise_url"];
            _recommenddataArray = dic [@"recommenddata"];
            _reviewdataDic = dic [@"reviewdata"];
            
            BOOL iscollect = [dic [@"goodsdata"] [@"iscollect"] boolValue];
            if (iscollect) {
                UIBarButtonItem *favItem = self.navigationItem.rightBarButtonItem;
                UIButton *favBtn = (UIButton *)favItem.customView;
                favBtn.selected = YES;
            }
            
            [self.myTableView reloadData];
        }
        else {
//            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:2];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:[responseObject objectForKey:MSG] delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil, nil];
            [alert show];
            
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
    if ([notification.name isEqualToString:SubmitCollect]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SubmitCollect object:nil];
        if ([responseObject[@"status"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            UIBarButtonItem *favItem = self.navigationItem.rightBarButtonItem;
            UIButton *favBtn = (UIButton *)favItem.customView;
            favBtn.selected = ! favBtn.selected; //修改按钮状态
        }
        else {
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
