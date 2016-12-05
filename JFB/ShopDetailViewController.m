//
//  ShopDetailViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/29.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "ShopDetailViewController.h"
#import "ShopDetailHeadCell.h"
#import "ShopDetailAddressCell.h"
#import "ShopDetailVoucherCell.h"
#import "ShopDetailGoodsCel.h"
#import "ShopDetailEvaluateCell.h"
#import "HomeShopListCell.h"
#import "DetailBottomNextCell.h"
#import "DJQRateView.h"
#import "GoodsDetailViewController.h"
#import "AllEvaluateViewController.h"
#import "MerchantAlbumListViewController.h"
#import "ShopMapNavigationViewController.h"
#import "ShopListVC.h"
#import "LoginViewController.h"

#define HeadCell    @"shopDetailHeadCell"   
#define AddressCell    @"shopDetailAddressCell"
#define VoucherCell    @"shopDetailVoucherCell"
#define GoodsCell    @"shopDetailGoodsCell"
#define EvaluateCell    @"shopDetailEvaluateCell"
#define BottomNextCell      @"detailBottomNextCell"
#define kTableViewCelllIdentifier      @"HomeShopCell"

@interface ShopDetailViewController () <UIAlertViewDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    
    NSArray *_goodsdataArray;    //商品信息数组
    NSArray *_recommendmerchantdataArray;    //附近商户数组
    NSDictionary *_reviewdataDic;    //评论数据字典
    
    NSString *flagStr; //收藏1，取消收藏2
}

@end 

@implementation ShopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商家详情";
    
    UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mapBtn.frame = CGRectMake(0, 0, 24, 24);
    mapBtn.contentMode = UIViewContentModeScaleAspectFit;
    [mapBtn setImage:[UIImage imageNamed:@"pd_sendto"] forState:UIControlStateNormal];
    [mapBtn addTarget:self action:@selector(toMapView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *mapBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:mapBtn];
    
    UIButton *favoriteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    favoriteBtn.frame = CGRectMake(0, 0, 24, 24);
    favoriteBtn.contentMode = UIViewContentModeScaleAspectFit;
    [favoriteBtn setImage:[UIImage imageNamed:@"ic_action_favorite_off_white"] forState:UIControlStateNormal];
    [favoriteBtn setImage:[UIImage imageNamed:@"ic_action_favorite_on"] forState:UIControlStateSelected];
    [favoriteBtn addTarget:self action:@selector(toFavorite:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *favoriteBarBtn = [[UIBarButtonItem alloc] initWithCustomView:favoriteBtn];
    
    NSArray *rightArr = [NSArray arrayWithObjects:favoriteBarBtn,mapBtnBarBtn, nil];
    self.navigationItem.rightBarButtonItems = rightArr;
    
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
     
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailHeadCell" bundle:nil] forCellReuseIdentifier:HeadCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailAddressCell" bundle:nil] forCellReuseIdentifier:AddressCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailVoucherCell" bundle:nil] forCellReuseIdentifier:VoucherCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailGoodsCel" bundle:nil] forCellReuseIdentifier:GoodsCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"ShopDetailEvaluateCell" bundle:nil] forCellReuseIdentifier:EvaluateCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"DetailBottomNextCell" bundle:nil] forCellReuseIdentifier:BottomNextCell];
    [self.myTableView registerNib:[UINib nibWithNibName:@"HomeShopListCell" bundle:nil] forCellReuseIdentifier:kTableViewCelllIdentifier];
    
    [self SetLayerWithBtn:self.typeBtn1];
    [self SetLayerWithBtn:self.typeBtn2];
    [self SetLayerWithBtn:self.typeBtn3];
    [self SetLayerWithBtn:self.typeBtn4];
    
    [self requestGetMerchantDetail];
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

-(void)SetLayerWithBtn:(UIButton *)btn {
    btn.layer.cornerRadius = 5;
    btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    btn.layer.borderWidth = 1;
}

-(void)toMapView {
    ShopMapNavigationViewController *mapVC = [[ShopMapNavigationViewController alloc] init];
//    mapVC.latitudeStr = self.merchantdataDic [@"latitude"];
//    mapVC.longitudeStr = self.merchantdataDic [@"longitude"];
    mapVC.shopDic = self.merchantdataDic;
    [self.navigationController pushViewController:mapVC animated:YES];
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

-(void)toTelPhone {
    NSString *phoneString = self.merchantdataDic [@"tel"];
    NSMutableString * str=[[NSMutableString alloc] initWithFormat:@"tel:%@",phoneString];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
    [self.view addSubview:callWebview];
}

-(void)merchantAlbumList {
    if ([self.merchantdataDic [@"picturecount"] intValue] > 0) {
        MerchantAlbumListViewController *albumVC = [[MerchantAlbumListViewController alloc] init];
        albumVC.merchant_id = self.merchantdataDic [@"merchant_id"];
        [self.navigationController pushViewController:albumVC animated:YES];
    }
    else {
        if (!_networkConditionHUD) {
            _networkConditionHUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:_networkConditionHUD];
        }
        _networkConditionHUD.labelText = @"商家还没有提供图片。此图片为LOGO";
        _networkConditionHUD.mode = MBProgressHUDModeText;
        _networkConditionHUD.yOffset = APP_HEIGHT/2 - HUDBottomH;
        _networkConditionHUD.margin = HUDMargin;
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (! [_goodsdataArray isKindOfClass:[NSNull class]]) {  //显示评价列
        return 6;
    }
    else {                                  //不显示评价列及代金券列
        return 4;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
     if (! [_goodsdataArray isKindOfClass:[NSNull class]]) {  //显示评价列
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return 1;
                break;
                
            case 2:     //代金券
                return [_goodsdataArray count];
                break;
                
            case 3:
                return 1;
                break;
                
            case 4:  //评价
                return 2;
                break;
                
            case 5:
                if ([_recommendmerchantdataArray count] > 0) {
                    return [_recommendmerchantdataArray count];
                }
                return 1;
                break;
                
            default:
                break;
        }
        return 0;
     }
     else {                 //不显示评价列
         switch (section) {
             case 0:
                 return 1;
                 break;
                 
             case 1:
                 return 1;
                 break;
                 
//             case 2:     //没有代金券
//                 return 1;
//                 break;
                 
             case 2:
                 return 1;
                 break;
                 
             case 3:
                 if ([_recommendmerchantdataArray count] > 0) {
                     return [_recommendmerchantdataArray count];
                 }
                 return 1;
                 break;
                 
             default:
                 break;
         }
         return 0;
     }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (! [_goodsdataArray isKindOfClass:[NSNull class]]) {  //显示评价列
        switch (indexPath.section) {
            case 0:
                return 210;
                break;
                
            case 1:
                return 55;
                break;
                
            case 2:  //代金券
                return 100;
                break;
                
            case 3: {
                UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
                NSLog(@"%f",cell.bounds.size.height);
                return cell.bounds.size.height;
            }
                break;
                
            case 4: {  //评价
                if (indexPath.row == 0) {
                    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
                    NSLog(@"%f",cell.bounds.size.height);
                    return cell.bounds.size.height;
                }
                else if (indexPath.row == 1)  {
                    return 44;
                }
            }
                break;
                
            case 5:
                return 100;
                break;
                
            default:
                break;
        }
        return 0;
    }
    else {                  //不显示评价列
        switch (indexPath.section) {
            case 0:
                return 210;
                break;
                
            case 1:
                return 55;
                break;
                
//            case 2:  //代金券
//                return 100;
//                break;
                
            case 2: {
                UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
                NSLog(@"%f",cell.bounds.size.height);
                return cell.bounds.size.height;
            }
                break;
                
            case 3:
                return 100;
                break;
                
            default:
                break;
        }
        return 0;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   if (! [_goodsdataArray isKindOfClass:[NSNull class]]) {  //显示评价列
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return 1;
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
                return 80;
                break;
                
            default:
                break;
        }
        return 0;
    }
    else {                  //不显示评价列
        switch (section) {
            case 0:
                return 1;
                break;
                
            case 1:
                return 1;
                break;
                
//            case 2:
//                return 44;
//                break;
                
            case 2:
                return 44;
                break;
                
            case 3:
                return 80;
                break;
                
            default:
                break;
        }
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (! [_goodsdataArray isKindOfClass:[NSNull class]]) {  //显示评价列
        switch (indexPath.section) {
            case 0: {
                ShopDetailHeadCell *cell = (ShopDetailHeadCell *)[tableView dequeueReusableCellWithIdentifier:HeadCell];

                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.bigIM sd_setImageWithURL:[NSURL URLWithString:self.merchantdataDic [@"background"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                cell.shopNameL.text = self.merchantdataDic [@"merchant_name"];
                cell.rateView.rate = [self.merchantdataDic [@"score"] floatValue];
                cell.scoreL.text = [NSString stringWithFormat:@"%@分",self.merchantdataDic [@"score"]];
                cell.fractionL.text = [NSString stringWithFormat:@"%@%%",self.merchantdataDic [@"fraction"]];
                [cell.imgsBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:self.merchantdataDic [@"merchant_logo"]] forState:UIControlStateNormal placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                if ([self.merchantdataDic [@"picturecount"] intValue] > 0) {    //图片数量大于0时，才显示数字
                    [cell.imgsBtn setTitle:[NSString stringWithFormat:@"%@",self.merchantdataDic [@"picturecount"]] forState:UIControlStateNormal];
                }
                [cell.imgsBtn addTarget:self action:@selector(merchantAlbumList) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
                break;
                
            case 1: {
                ShopDetailAddressCell *cell = (ShopDetailAddressCell *)[tableView dequeueReusableCellWithIdentifier:AddressCell];
                cell.addressL.text = self.merchantdataDic [@"address"];
                [cell.mapAddressBtn addTarget:self action:@selector(toMapView) forControlEvents:UIControlEventTouchUpInside];
                NSString *phoneString = self.merchantdataDic [@"tel"];
                if (! [phoneString isKindOfClass:[NSNull class]]) {
                    cell.phoneViewWidthCons.constant = 62;
                    [cell.phoneBtn addTarget:self action:@selector(toTelPhone) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    cell.phoneViewWidthCons.constant = 0;
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
                
            case 2: {
                ShopDetailVoucherCell *cell = (ShopDetailVoucherCell *)[tableView dequeueReusableCellWithIdentifier:VoucherCell];
                
                NSDictionary *dic = _goodsdataArray [indexPath.row];
                
                cell.emptyL.hidden = YES;
                cell.voucherView.hidden = NO;
                [cell.voucherIM sd_setImageWithURL:[NSURL URLWithString:dic [@"cover_Image"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                cell.nameL.text = dic [@"goods_name"];
                cell.priceL.text = [NSString stringWithFormat:@"%@元",dic[@"sales_price"]];
                cell.costPriceStrikeL.text = [NSString stringWithFormat:@"%@元",dic[@"market_price"]];
                cell.saleL.text = [NSString stringWithFormat:@"已售:%@",dic[@"sales"]];

                return cell;
            }
                break;
                
            case 3: {
                ShopDetailGoodsCel *cell = (ShopDetailGoodsCel *)[tableView dequeueReusableCellWithIdentifier:GoodsCell];
                NSString *merchant_info = self.merchantdataDic [@"merchant_info"];
                if ([merchant_info isEqualToString:@""]) {
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
                break;
                
            case 4: {
                if (indexPath.row == 0) {
                    if ([_reviewdataDic [@"totalcount"] intValue] > 0) {
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
                    else {
                        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                        cell.textLabel.textAlignment = NSTextAlignmentCenter;
                        cell.textLabel.font = [UIFont systemFontOfSize:17];
                        cell.textLabel.text = @"暂无数据";
                        return cell;
                    }
                }
                else if (indexPath.row == 1) {
                    DetailBottomNextCell *cell = (DetailBottomNextCell *)[tableView dequeueReusableCellWithIdentifier:BottomNextCell];
                    if (! _reviewdataDic [@"totalcount"]) {
                        cell.nextNoticeL.text = @"查看全部评论";
                    }
                    else {
                        cell.nextNoticeL.text = [NSString stringWithFormat:@"查看全部评论(%@)",_reviewdataDic [@"totalcount"]];
                    }
                    
                    return cell;
                }
            }
                break;
                
            case 5: {
                if ([_recommendmerchantdataArray count] > 0) {
                    NSDictionary *dic = _recommendmerchantdataArray [indexPath.row];
                    HomeShopListCell *cell = (HomeShopListCell *)[tableView dequeueReusableCellWithIdentifier:kTableViewCelllIdentifier];
                    
                    [cell.shopIM sd_setImageWithURL:[NSURL URLWithString:dic[@"merchant_logo"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                    cell.shopNameL.text = dic[@"merchant_name"];
                    cell.shopAddressL.text = dic[@"address"];
                    cell.rateView.rate = [dic[@"score"] floatValue];
                    cell.scoreL.text = [NSString stringWithFormat:@"%@分",dic[@"score"]];
                    cell.integralRateL.text = [NSString stringWithFormat:@"%@%%",dic[@"fraction"]];
                    
                    float dis = [dic[@"distance"] floatValue];
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
                else {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.font = [UIFont systemFontOfSize:17];
                    cell.textLabel.text = @"暂无数据";
                    return cell;
                }
                
            }
                break;
                
            default:
                break;
        }
        
        
        return nil;
    }
    else {              //不显示评价列
        switch (indexPath.section) {
            case 0: {
                ShopDetailHeadCell *cell = (ShopDetailHeadCell *)[tableView dequeueReusableCellWithIdentifier:HeadCell];
                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.bigIM sd_setImageWithURL:[NSURL URLWithString:self.merchantdataDic [@"background"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                cell.shopNameL.text = self.merchantdataDic [@"merchant_name"];
                cell.rateView.rate = [self.merchantdataDic [@"score"] floatValue];
                cell.scoreL.text = [NSString stringWithFormat:@"%@分",self.merchantdataDic [@"score"]];
                cell.fractionL.text = [NSString stringWithFormat:@"%@%%",self.merchantdataDic [@"fraction"]];
                [cell.imgsBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:self.merchantdataDic [@"merchant_logo"]] forState:UIControlStateNormal placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
//                [cell.imgsBtn setTitle:[NSString stringWithFormat:@"%@",self.merchantdataDic [@"picturecount"]] forState:UIControlStateNormal];
                if ([self.merchantdataDic [@"picturecount"] intValue] > 0) {    //图片数量大于0时，才显示数字
                    [cell.imgsBtn setTitle:[NSString stringWithFormat:@"%@",self.merchantdataDic [@"picturecount"]] forState:UIControlStateNormal];
                }
                [cell.imgsBtn addTarget:self action:@selector(merchantAlbumList) forControlEvents:UIControlEventTouchUpInside];
                return cell;
            }
                break;
                
            case 1: {
                ShopDetailAddressCell *cell = (ShopDetailAddressCell *)[tableView dequeueReusableCellWithIdentifier:AddressCell];
                cell.addressL.text = self.merchantdataDic [@"address"];
                [cell.mapAddressBtn addTarget:self action:@selector(toMapView) forControlEvents:UIControlEventTouchUpInside];
                NSString *phoneString = self.merchantdataDic [@"tel"];
                if (! [phoneString isKindOfClass:[NSNull class]]) {
                    cell.phoneViewWidthCons.constant = 62;
                    [cell.phoneBtn addTarget:self action:@selector(toTelPhone) forControlEvents:UIControlEventTouchUpInside];
                }
                else {
                    cell.phoneViewWidthCons.constant = 0;
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                return cell;
            }
                break;
                
//            case 2: {
//                ShopDetailVoucherCell *cell = (ShopDetailVoucherCell *)[tableView dequeueReusableCellWithIdentifier:VoucherCell];
//                
//                cell.emptyL.hidden = NO;
//                cell.voucherView.hidden = YES;
//                
//                return cell;
//            }
//                break;
                
            case 2: {
                ShopDetailGoodsCel *cell = (ShopDetailGoodsCel *)[tableView dequeueReusableCellWithIdentifier:GoodsCell];
                NSString *merchant_info = self.merchantdataDic [@"merchant_info"];
                if ([merchant_info isEqualToString:@""]) {
                    cell.emptyL.hidden = NO;
                    cell.contentL.hidden = YES;
                }
                else {
                    cell.emptyL.hidden = YES;
                    cell.contentL.hidden = NO;
                    cell.contentL.text = self.merchantdataDic [@"merchant_info"];
                }
                [cell.contentL sizeToFit];
                CGRect rect = cell.bounds;
                rect.size.height = 8 + cell.contentL.bounds.size.height + 8 + 21;
                cell.bounds = rect;
                
                return cell;
            }
                break;
                
            case 3: {
                if ([_recommendmerchantdataArray count] > 0) {
                    NSDictionary *dic = _recommendmerchantdataArray [indexPath.row];
                    HomeShopListCell *cell = (HomeShopListCell *)[tableView dequeueReusableCellWithIdentifier:kTableViewCelllIdentifier];
                    
                    [cell.shopIM sd_setImageWithURL:[NSURL URLWithString:dic[@"merchant_logo"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                    cell.shopNameL.text = dic[@"merchant_name"];
                    cell.shopAddressL.text = dic[@"address"];
                    cell.rateView.rate = [dic[@"score"] floatValue];
                    cell.scoreL.text = [NSString stringWithFormat:@"%@分",dic[@"score"]];
                    cell.integralRateL.text = [NSString stringWithFormat:@"%@%%",dic[@"fraction"]];
                    
                    float dis = [dic[@"distance"] floatValue];
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
                else {
                    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    cell.textLabel.font = [UIFont systemFontOfSize:17];
                    cell.textLabel.text = @"暂无数据";
                    return cell;
                }

            }
                break;
                
            default:
                break;
        }
        
        
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (! [_goodsdataArray isKindOfClass:[NSNull class]]) {  //显示评价列
        switch (section) {
            case 0:
                return nil;
                break;
                
            case 1:
                return nil;
                break;
                
            case 2: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = [NSString stringWithFormat:@"代金券(%lu)",(unsigned long)[_goodsdataArray count]];
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
                noticeL.text = @"商家详情";
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
                
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 40, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"评价";
                [headView addSubview:noticeL];
                
                DJQRateView *rateView = [[DJQRateView alloc] initWithFrame:CGRectMake(58, 12, 100, 20)];
                rateView.rate = [self.merchantdataDic [@"score"] floatValue];
                [headView addSubview:rateView];
                
                UILabel *scoreL = [[UILabel alloc] initWithFrame:CGRectMake(166, 0, 80, 44)];
                scoreL.textColor = RGBCOLOR(255, 116, 0);
                scoreL.text = [NSString stringWithFormat:@"%@分",self.merchantdataDic [@"score"]];
                [headView addSubview:scoreL];
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
                return headView;
            }
                break;
                
            case 5: {
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [self.nearbyHeadView addSubview:lineL];
                
                return self.nearbyHeadView;
            }
                break;
                
            default:
                break;
        }
        return nil;
    }
    else {          //不显示评价列
        switch (section) {
            case 0:
                return nil;
                break;
                
            case 1:
                return nil;
                break;
                
//            case 2: {
//                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
//                headView.backgroundColor = [UIColor whiteColor];
//                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
//                noticeL.textColor = [UIColor grayColor];
//                noticeL.text = @"代金券(0)";
//                [headView addSubview:noticeL];
//                
//                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
//                lineL.backgroundColor = Cell_sepLineColor;
//                [headView addSubview:lineL];
//                
//                return headView;
//            }
//                break;
                
            case 2: {
                UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                headView.backgroundColor = [UIColor whiteColor];
                UILabel *noticeL = [[UILabel alloc] initWithFrame:CGRectMake(8, 0, SCREEN_WIDTH - 16, 44)];
                noticeL.textColor = [UIColor grayColor];
                noticeL.text = @"商家详情";
                [headView addSubview:noticeL];
                
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [headView addSubview:lineL];
                
                return headView;
            }
                break;
                
            case 3: {
                UILabel *lineL = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
                lineL.backgroundColor = Cell_sepLineColor;
                [self.nearbyHeadView addSubview:lineL];
                
                return self.nearbyHeadView;
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
    if (! [_goodsdataArray isKindOfClass:[NSNull class]]) {  //显示评价列
        if (indexPath.section == 2) {   //商品
            NSDictionary *dic = _goodsdataArray [indexPath.row];
            GoodsDetailViewController *detailVC = [[GoodsDetailViewController alloc] init];
            detailVC.goods_id = dic [@"goods_id"];
            detailVC.merchant_id = self.merchantdataDic [@"merchant_id"];
            [self.navigationController pushViewController:detailVC animated:YES];
        }
        else if (indexPath.section == 4) {  //评价
            if (indexPath.row == 1) {
                //全部评价列表页
                AllEvaluateViewController *allVC = [[AllEvaluateViewController alloc] init];
                allVC.merchant_id = self.merchantdataDic [@"merchant_id"];
                allVC.goods_id = @"";  //商户详情点击进入，商品ID传@""
                [self.navigationController pushViewController:allVC animated:YES];
            }
        }
        else if (indexPath.section == 5) {
            if ([_recommendmerchantdataArray count] > 0) {
                NSDictionary *dic = _recommendmerchantdataArray [indexPath.row];
                ShopDetailViewController *detailVC = [[ShopDetailViewController alloc] init];
                detailVC.merchantdataDic = dic;
                detailVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detailVC animated:YES];
            }
        }
    }
    else {                      //不显示评价列
        if (indexPath.section == 3) {
            if ([_recommendmerchantdataArray count] > 0) {
                NSDictionary *dic = _recommendmerchantdataArray [indexPath.row];
                ShopDetailViewController *detailVC = [[ShopDetailViewController alloc] init];
                detailVC.merchantdataDic = dic;
                detailVC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:detailVC animated:YES];
            }
        }
    }

    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction)typesBtnAction:(id)sender {
    
    UIButton *btn = (UIButton *)sender;
    int codeInt = (int)btn.tag - 1000;
    if (codeInt == 2000) {  //全部
        ShopListVC *listVC = [[ShopListVC alloc] init];
        listVC.menu_subtitle = @"全部分类";
        listVC.menu_code = @"";
        listVC.typeID = @"";
        [listVC.typeBtn setTitle:@"全部分类" forState:UIControlStateNormal];
        [self.navigationController pushViewController:listVC animated:YES];
        
    }
    else {
        ShopListVC *listVC = [[ShopListVC alloc] init];
        listVC.menu_subtitle = btn.currentTitle;
        listVC.menu_code = [NSString stringWithFormat:@"%d",codeInt];
        listVC.typeID = [NSString stringWithFormat:@"%d",codeInt];
        [listVC.typeBtn setTitle:btn.currentTitle forState:UIControlStateNormal];
        [self.navigationController pushViewController:listVC animated:YES];
    }

}


#pragma mark - UIAlertViewDelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 4040) {
        if (buttonIndex == 1) {
            LoginViewController *loginVC = [[LoginViewController alloc] init];
            loginVC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:loginVC animated:YES];
        }
    }
}

#pragma mark - 发送请求
-(void)requestGetMerchantDetail { //获取商户详情
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetMerchantDetailInfo object:nil];
    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetMerchantDetailInfo, @"op", nil];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.merchantdataDic [@"merchant_id"],@"merchant_id",[locationDic objectForKey:@"latitude"],@"latitude",[locationDic objectForKey:@"longitude"],@"longitude",userID,@"member_id", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetMerchantDetailInfo) delegate:nil params:pram info:infoDic];
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
//    @"collect_type":@"1" //商户收藏
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:self.merchantdataDic [@"merchant_id"],@"collect_id",@"1",@"collect_type",userID,@"member_id",flagStr,@"flag", nil];
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
    NSLog(@"GetMerchantDetailInfo_: %@",responseObject);
    if ([notification.name isEqualToString:GetMerchantDetailInfo]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetMerchantDetailInfo object:nil];
        if ([responseObject[@"status"] boolValue]) {
            NSDictionary *dic = responseObject [DATA];
            self.merchantdataDic = dic [@"merchantdata"];  //商户信息数据字典
            _goodsdataArray = dic [@"goodsdata"];    //商品信息数组
            _recommendmerchantdataArray = dic [@"recommendmerchantdata"];    //附近商户数组
            _reviewdataDic = dic [@"reviewdata"];    //评论数据字典
            
            BOOL iscollect = [dic [@"merchantdata"] [@"iscollect"] boolValue];
            if (iscollect) {
                NSArray *items = self.navigationItem.rightBarButtonItems;
                UIBarButtonItem *favItem = [items firstObject];
                UIButton *favBtn = (UIButton *)favItem.customView;
                favBtn.selected = YES;
            }
            [self.myTableView reloadData]; 
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        }
        
        
        /**************  第一个当前商户的类型，中间随机首页商户类型两个，最后一个全部。    ******************/
        [self.typeBtn1 setTitle:self.merchantdataDic[@"type_name"] forState:UIControlStateNormal];
        self.typeBtn1.tag = [self.merchantdataDic[@"type_code"]  intValue] + 1000;
        
        //全部类型不再数组中，所以tag值固定3000
        [self.typeBtn4 setTitle:@"全部分类" forState:UIControlStateNormal];
        self.typeBtn4.tag = 2000 + 1000;
        
        //随机产生不同的两个商户类型
        NSDictionary *typeDic = [[GlobalSetting shareGlobalSettingInstance] merchantTypeList];
        NSMutableArray *merchantTypeArray = [typeDic [DATA] mutableCopy];
        /***************  剔除掉当前商户的类型，防止中间两个跟第一个有重复  ****************/
        for (NSDictionary *dic in merchantTypeArray) {
            if ([dic[@"menu_code"] isEqualToString:self.merchantdataDic[@"type_code"]]) {
                [merchantTypeArray removeObject:dic];
            }
        }
        
        NSMutableSet *randomSet = [[NSMutableSet alloc] init];
        
        while ([randomSet count] < 2) { //随机抽取两个
            int r = arc4random() % [merchantTypeArray count];
            [randomSet addObject:merchantTypeArray [r]];
        }
        NSArray *randomArray = [randomSet allObjects];
        
        NSDictionary *typeDiction = [randomArray firstObject];
        [self.typeBtn2 setTitle:typeDiction[@"menu_subtitle"] forState:UIControlStateNormal];
        self.typeBtn2.tag = [typeDiction[@"menu_code"] intValue] + 1000;
        
        NSDictionary *typeDiction3 = [randomArray lastObject];
        [self.typeBtn3 setTitle:typeDiction3[@"menu_subtitle"] forState:UIControlStateNormal];
        self.typeBtn3.tag = [typeDiction3[@"menu_code"] intValue] + 1000;
        /**********************************************************************************/
        
    }
    
    if ([notification.name isEqualToString:SubmitCollect]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:SubmitCollect object:nil];
        if ([responseObject[@"status"] boolValue]) {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            NSArray *items = self.navigationItem.rightBarButtonItems;
            UIBarButtonItem *favItem = [items firstObject];
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
