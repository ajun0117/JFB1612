//
//  ShopListVC.m
//  JFB
//
//  Created by LYD on 15/9/22.
//  Copyright © 2015年 李俊阳. All rights reserved.
//

#import "ShopListVC.h"
#import "HomeShopListCell.h"
#import "ShopDetailViewController.h"
#import "MJRefresh.h"
#import <BaiduMapAPI/BMapKit.h>//引入所有的头文件
#import "ShopMapViewController.h"
#import "ShopSearchViewController.h"
//#import "CityObject.h"
//#import "CountysObject.h"
#import "OrderRefundViewController.h"
#import "AppDelegate.h"
#import "CityDistrictsCoreObject.h"

#define kTableViewCelllIdentifier      @"HomeShopCell"

@interface ShopListVC () <BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    NSMutableArray *shopArray;
    int currentpage;
    BMKLocationService* _locService;
    BMKGeoCodeSearch *_searcher;
    NSArray *selectArray;
    NSString *typeID;
    NSString *cityID;   //城市
    NSString *countyID;    //区县
    NSString *countyName;   //区县名称
    NSString *sortID;   //排序
    NSArray *countysArray;  //区县数组
    NSString *current_city_code;
    NSString *current_county_code;
}

@end

@implementation ShopListVC
@synthesize typeID;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent = NO;
    self.title = @"商家";
    
    UIButton *mapBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    mapBtn.frame = CGRectMake(0, 0, 24, 24);
    mapBtn.contentMode = UIViewContentModeScaleAspectFit;
    [mapBtn setImage:[UIImage imageNamed:@"pd_sendto"] forState:UIControlStateNormal];
    [mapBtn addTarget:self action:@selector(toMapView) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *mapBtnBarBtn = [[UIBarButtonItem alloc] initWithCustomView:mapBtn];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    searchBtn.frame = CGRectMake(0, 0, 24, 24);
    searchBtn.contentMode = UIViewContentModeScaleAspectFit;
    [searchBtn setImage:[UIImage imageNamed:@"square_searchrecommend_search_icon"] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(toSearch) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *searchBarBtn = [[UIBarButtonItem alloc] initWithCustomView:searchBtn];
    
    NSArray *rightArr = [NSArray arrayWithObjects:searchBarBtn,mapBtnBarBtn, nil];
    self.navigationItem.rightBarButtonItems = rightArr;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap)];
    [self.selectBgView addGestureRecognizer:tap];
    
    currentpage = 1; //默认首页
    shopArray = [[NSMutableArray alloc] init];
    [self.myTableView registerNib:[UINib nibWithNibName:@"HomeShopListCell" bundle:nil] forCellReuseIdentifier:kTableViewCelllIdentifier];
    [self.myTableView addHeaderWithTarget:self action:@selector(headerRefreshing)];
    [self.myTableView addFooterWithTarget:self action:@selector(footerLoadData)];
    self.myTableView.tableFooterView = [UIView new];
    
    self.selectTableView.tableFooterView = [UIView new];
    
    _locService = [[BMKLocationService alloc]init];
    [_locService startUserLocationService];
    //            初始化检索对象
    _searcher = [[BMKGeoCodeSearch alloc]init];
    
    if (! self.menu_subtitle) {
        self.menu_subtitle = @"全部分类";
    }
    NSLog(@"menu_code: %@",self.menu_code);
    [self.typeBtn setTitle:self.menu_subtitle forState:UIControlStateNormal];
    //    self.title = self.menu_subtitle;
    
    NSDictionary *typeDic = [[GlobalSetting shareGlobalSettingInstance] merchantTypeList];
    selectArray = typeDic [DATA];
    
    //初始化
    if (sortID == nil) {
        sortID = @"2";   //默认距离排序
    }
    NSLog(@"typeID:   %@",typeID);
    if (typeID == nil) {
        typeID = @"";
    }
}

-(void)tap {
    self.selectBgView.hidden = YES;
    self.selectTableView.hidden = YES;
}

-(void)toMapView {
    ShopMapViewController *mapVC = [[ShopMapViewController alloc] init];
    mapVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:mapVC animated:YES];
}

-(void)toSearch {
    NSLog(@"推出搜索页");
    ShopSearchViewController *searchVC = [[ShopSearchViewController alloc] init];
    searchVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:searchVC animated:YES];
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
    
    
    NSMutableDictionary *dic = [[GlobalSetting shareGlobalSettingInstance] homeSelectedDic];
    NSLog(@"dic:  %@",dic);
    if ([cityID isEqualToString:dic[@"cityID"]] && [countyID isEqualToString:dic[@"countyID"]]) {
        return;
    }
    
    NSString *cityName;
    if (dic != nil) {
        //        selectItem = [dic[@"selectItem"] integerValue];
        cityID = dic[@"cityID"];
        cityName = dic [@"areaName"];
        countyID = dic[@"countyID"];
        countyName = dic[@"countName"];
        current_city_code = dic[@"current_city_code"];
        current_county_code = dic[@"current_county_code"];
        
        if ([countyName isEqualToString:@""]) {
            [self.countyBtn setTitle:@"全部区县" forState:UIControlStateNormal];
        }
        else {
            [self.countyBtn setTitle:countyName forState:UIControlStateNormal];
        }
    }
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    CityDistrictsCoreObject *cityObject = [app selectDataWithName:cityName];    //获取对应城市对象
    NSString *parentID = cityObject.areaId;
    countysArray = [app selectDataWithParentID:parentID];   //获取对应区县数组对象
    
    
    //    [self requestGetRecommendShopList];
    [self.myTableView headerBeginRefreshing];
}

-(void)viewWillAppear:(BOOL)animated {
    _locService.delegate = self;
    _searcher.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    _locService.delegate = nil;
    _searcher.delegate = nil;
}

#pragma mark - 定位成功代理
- (void)didFailToLocateUserWithError:(NSError *)error {
    [_locService stopUserLocationService];
    
    /************  定位失败，赋初值 *************/
    NSDictionary *locationDic = [NSDictionary dictionaryWithObjectsAndKeys:Latitude,@"latitude",Longitude,@"longitude", nil];
    //存储当前位置坐标
    [[GlobalSetting shareGlobalSettingInstance] setMyLocationWithDic:locationDic];
    
    self.locationL.text = @"获取位置失败";
    
    NSLog(@"error is %@",[error description]);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"定位失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if (userLocation) {
        [_locService stopUserLocationService];
        [self getReverseGeoCodeWithLocation:userLocation];
        
        NSString *locationCoordinateStr = [NSString stringWithFormat:@"{\"latitude\":%f,\"longitude\":%f}",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
        NSLog(@"locationCoordinateStr: %@",locationCoordinateStr);
        
        NSString *lat = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
        NSString *lon = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
        NSDictionary *locationDic = [NSDictionary dictionaryWithObjectsAndKeys:lat,@"latitude",lon,@"longitude", nil];
        //存储当前位置坐标
        [[GlobalSetting shareGlobalSettingInstance] setMyLocationWithDic:locationDic];
        
        //        [self requestGetRecommendShopList];
        //        [self.myTableView headerBeginRefreshing]; //自动刷新
        
    }
}

-(void)getReverseGeoCodeWithLocation:(BMKUserLocation *)userLocation
{
    //            发起反向地理编码检索
    CLLocationCoordinate2D pt = userLocation.location.coordinate;
    NSLog(@"%lf,%lf",pt.latitude,pt.longitude);
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[
                                                            BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

//接收反向地理编码结果
-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
(BMKReverseGeoCodeResult *)result
                        errorCode:(BMKSearchErrorCode)error{
    if (error == BMK_SEARCH_NO_ERROR) {
        //      在此处理正常结果
        NSLog(@"result.addressDetail.city: %@,result.addressDetail.streetName: %@,result.address: %@",result.addressDetail.city,result.addressDetail.streetName,result.address);
        NSString *cityNameStr = result.addressDetail.city;
        if ([cityNameStr length] > 0) {
            self.locationL.text = result.address;
        }
        else {
            self.locationL.text = @"衡阳市街道";    //国外坐标默认显示衡阳街道
        }
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取城市信息失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark - 下拉刷新,上拉加载
-(void)headerRefreshing {
    NSLog(@"下拉刷新个人信息");
    currentpage = 1;
    //    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    [self requestGetRecommendShopList];
}

-(void)footerLoadData {
    NSLog(@"上拉加载数据");
    currentpage ++;
    //    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    [self requestGetRecommendShopList];
}


- (IBAction)typeAction:(id)sender {
    NSDictionary *typeDic = [[GlobalSetting shareGlobalSettingInstance] merchantTypeList];
    selectArray = typeDic [DATA];
    
    self.typeBtn.selected = YES;
    self.countyBtn.selected = NO;
    self.orderBtn.selected = NO;
    [self.selectTableView reloadData];
    
    self.selectBgView.hidden = NO;
    self.selectTableView.hidden = NO;
}

- (IBAction)countyAction:(id)sender {
    selectArray = countysArray;
    
    self.typeBtn.selected = NO;
    self.countyBtn.selected = YES;
    self.orderBtn.selected = NO;
    [self.selectTableView reloadData];
    
    self.selectBgView.hidden = NO;
    self.selectTableView.hidden = NO;
}

- (IBAction)orderAction:(id)sender {
    selectArray = @[@"离我最近",@"积分率最高"];
    
    self.typeBtn.selected = NO;
    self.countyBtn.selected = NO;
    self.orderBtn.selected = YES;
    [self.selectTableView reloadData];
    
    self.selectBgView.hidden = NO;
    self.selectTableView.hidden = NO;
}

- (IBAction)refreshAction:(id)sender {
    [UIView animateWithDuration:0.5 animations:^{
        self.refreshBtn.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        self.refreshBtn.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:0.5 animations:^{
        self.refreshBtn.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        self.refreshBtn.transform = CGAffineTransformIdentity;
    }];
    
    [_locService startUserLocationService];
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
    if (tableView == self.selectTableView) {
        if (self.typeBtn.selected || self.countyBtn.selected) {
            return [selectArray count] +1;  //增加全部选项
        }
        return [selectArray count];
    }
    
    return [shopArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.selectTableView) {
        return 44;
    }
    return 100;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.selectTableView) {
        return 0;
    }
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.selectTableView) {
        
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (self.typeBtn.selected) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"全部分类";
            }
            else {
                //                [cell.imageView sd_setImageWithURL:[NSURL URLWithString:dic [@"icon_url"]] placeholderImage:IMG(@"bg_merchant_photo_placeholder")];
                NSDictionary *dic = selectArray [indexPath.row - 1];
                cell.textLabel.text = dic [@"menu_subtitle"];
            }
        }
        else if (self.countyBtn.selected) {
            if (indexPath.row == 0) {
                cell.textLabel.text = @"全部区县";
            }
            else {
                CityDistrictsCoreObject *county = (CityDistrictsCoreObject *)selectArray [indexPath.row - 1];
                cell.textLabel.text = county.areaName;
            }
        }
        else if (self.orderBtn.selected) {
            cell.textLabel.text = selectArray [indexPath.row];
        }
        
        return  cell;
    }
    else {
        NSDictionary *dic = shopArray [indexPath.row];
        
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
    if (tableView == self.selectTableView) {
        
        if (self.typeBtn.selected) {
            if (indexPath.row == 0) {
                typeID = @"";
                [self.typeBtn setTitle:@"全部分类" forState:UIControlStateNormal];
                //                self.title = @"全部分类";
            }
            else {
                NSDictionary *dic = selectArray [indexPath.row - 1];
                typeID = [NSString stringWithFormat:@"%@",dic[@"menu_code"]];
                [self.typeBtn setTitle:dic[@"menu_subtitle"] forState:UIControlStateNormal];
                //                self.title = dic[@"menu_subtitle"];
            }
        }
        else if (self.countyBtn.selected) {
            if (indexPath.row == 0) {
                countyID = @"";
                current_county_code = @"";
                [self.countyBtn setTitle:@"全部区县" forState:UIControlStateNormal];
            }
            else {
                CityDistrictsCoreObject *county = (CityDistrictsCoreObject *)selectArray [indexPath.row - 1];
                countyID = [NSString stringWithFormat:@"%@",county.areaId];
                current_county_code = county.current_code;
                [self.countyBtn setTitle:county.areaName forState:UIControlStateNormal];
            }
        }
        else {
            sortID = [NSString stringWithFormat:@"%ld",(long)indexPath.row + 2];
            [self.orderBtn setTitle:selectArray[indexPath.row] forState:UIControlStateNormal];
        }
        
        self.selectBgView.hidden = YES;
        self.selectTableView.hidden = YES;
        
        currentpage = 1;
        [self requestGetRecommendShopList];
    }
    else {
        NSDictionary *dic = shopArray [indexPath.row];
        ShopDetailViewController *detailVC = [[ShopDetailViewController alloc] init];
        detailVC.merchantdataDic = dic;
        detailVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:detailVC animated:YES];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark - 网络请求
-(void)requestGetRecommendShopList { //获取推荐商户列表
    [_hud show:YES];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetMerchantList object:nil];
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetMerchantList, @"op", nil];
    NSDictionary *locationDic = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    NSString *userID = [[GlobalSetting shareGlobalSettingInstance] userID];
    if (userID == nil) {
        userID = @"";
    }
    NSLog(@"cityID: %@",cityID);
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:current_city_code,@"current_city_code",current_county_code,@"current_county_code",cityID,@"city",countyID,@"county",cityID,@"current_city_code",countyID,@"current_county_code",typeID,@"business_type",sortID,@"sort",[NSNumber numberWithInt:currentpage],@"pageindex",@"",@"key",userID,@"member_id",[locationDic objectForKey:@"latitude"],@"latitude",[locationDic objectForKey:@"longitude"],@"longitude", nil];
    NSLog(@"pram: %@",pram);
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetMerchantList) delegate:nil params:pram info:infoDic];
}


#pragma mark - 网络请求结果数据
-(void) didFinishedRequestData:(NSNotification *)notification{
    [_hud hide:YES];
    
    [self.myTableView headerEndRefreshing];
    [self.myTableView footerEndRefreshing];
    if ([[notification.userInfo valueForKey:@"RespResult"] isEqualToString:ERROR]) {
        _networkConditionHUD.labelText = [notification.userInfo valueForKey:@"ContentResult"];
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
        return;
    }
    NSDictionary *responseObject = [[NSDictionary alloc] initWithDictionary:[notification.userInfo objectForKey:@"RespData"]];
    if ([notification.name isEqualToString:GetMerchantList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetMerchantList object:nil];
        
        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
            if (currentpage == 1) { //如果是第一页
                [shopArray removeAllObjects];
            }
            [shopArray addObjectsFromArray:responseObject[DATA]];
        }
        else {
            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
            [_networkConditionHUD show:YES];
            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            if (currentpage == 1) { //如果是第一页
                [shopArray removeAllObjects];
            }
        }
        [self.myTableView reloadData];
        
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
