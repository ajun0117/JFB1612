//
//  ShopMapNavigationViewController.m
//  JFB
//
//  Created by LYD on 15/9/17.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "ShopMapNavigationViewController.h"
#import "MyAnnotationView.h"
#import "RouteSearchViewController.h"

static NSString *AnnotationViewID = @"MyAnnotation";

@interface ShopMapNavigationViewController () <BMKRouteSearchDelegate,BMKGeoCodeSearchDelegate,UIActionSheetDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    BMKMapView *_myMapView;
    BMKLocationService* _locService;
    BMKRouteSearch *_searcher;
    BMKGeoCodeSearch *_geoCodeSearcher;
    NSString *streetStr;
    NSString *cityStr;
//    NSInteger annoTag;
}

@end

@implementation ShopMapNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商家地址";
    
    self.routeSearchBtn.layer.borderColor = Cell_sepLineColor.CGColor;
    self.routeSearchBtn.layer.borderWidth = 1;
    self.locationmapBtn.layer.borderColor = Cell_sepLineColor.CGColor;
    self.locationmapBtn.layer.borderWidth = 1;
    
    _myMapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64 - 100)];
    [self.view addSubview:_myMapView];
    //    [_myMapView showsUserLocation]; 
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
    
    _locService = [[BMKLocationService alloc]init];
    [_locService startUserLocationService];
    
    //            初始化检索对象
    _geoCodeSearcher = [[BMKGeoCodeSearch alloc]init];
    
    self.shopNameL.text = self.shopDic [@"merchant_name"];
    self.shopAddressL.text = self.shopDic [@"address"];
    
    //商家坐标
    CLLocationCoordinate2D coor;
    coor.latitude = [self.shopDic [@"latitude"] doubleValue];
    coor.longitude = [self.shopDic [@"longitude"] doubleValue];
    [_myMapView setCenterCoordinate:coor];
    [_myMapView setZoomLevel:17];

    [_myMapView showsUserLocation];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //商家坐标
    CLLocationCoordinate2D coor;
    coor.latitude = [self.shopDic [@"latitude"] doubleValue];
    coor.longitude = [self.shopDic [@"longitude"] doubleValue];
    // 添加一个PointAnnotation
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = coor;
    annotation.title = self.shopDic [@"merchant_name"];
    [_myMapView addAnnotation:annotation];
    
    [_myMapView selectAnnotation:annotation animated:YES];
}

#pragma mark - 打开手机地图导航
-(void)openBaiduMapRoute {
    //打开地图驾车路线检索
    BMKOpenDrivingRouteOption *opt = [[BMKOpenDrivingRouteOption alloc] init];
    opt.appScheme = @"baidumapJFB";//用于调起成功后，返回原应用
    //初始化起点节点
    BMKPlanNode* start = [[BMKPlanNode alloc]init];
    //指定起点经纬度
    CLLocationCoordinate2D myCoor;
    NSDictionary *myLocation = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    myCoor.latitude = [myLocation [@"latitude"] floatValue];
    myCoor.longitude = [myLocation [@"longitude"] floatValue];
    //指定起点名称
    start.name = @"我的位置";
    start.pt = myCoor;
    //指定起点
    opt.startPoint = start;
    
    //初始化终点节点
    BMKPlanNode* end = [[BMKPlanNode alloc]init];
    //商家坐标
    CLLocationCoordinate2D coor;
    coor.latitude = [self.shopDic [@"latitude"] doubleValue];
    coor.longitude = [self.shopDic [@"longitude"] doubleValue];
    end.pt = coor;
    //指定终点名称
    end.name = self.shopDic [@"merchant_name"];
    opt.endPoint = end;
    
    BMKOpenErrorCode code = [BMKOpenRoute openBaiduMapDrivingRoute:opt];
    if(code == BMK_OPEN_NO_ERROR)
    {
        NSLog(@"成功");
    }
    else
    {
        NSLog(@"失败");
    }
    
}

#pragma mark - 定位代理
//实现相关delegate 处理位置信息更新
//处理方向变更信息
//- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
//{
//    NSLog(@"heading is %@",userLocation.heading);
//}

- (void)didFailToLocateUserWithError:(NSError *)error {
    [_locService stopUserLocationService];
    
    /************  定位失败，赋初值 *************/
    NSDictionary *locationDic = [NSDictionary dictionaryWithObjectsAndKeys:Latitude,@"latitude",Longitude,@"longitude", nil];
    //存储当前位置坐标
    [[GlobalSetting shareGlobalSettingInstance] setMyLocationWithDic:locationDic];
    
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
        
    }
}


-(void)getReverseGeoCodeWithLocation:(BMKUserLocation *)userLocation
{
    //            发起反向地理编码检索
    CLLocationCoordinate2D pt = userLocation.location.coordinate;
    NSLog(@"%lf,%lf",pt.latitude,pt.longitude);
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geoCodeSearcher reverseGeoCode:reverseGeoCodeSearchOption];
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
        NSString *streetName = result.addressDetail.streetName;
        NSString *cityName = result.addressDetail.city;
        if ([streetName length] > 0) {
            streetStr = streetName;
        }
        else {
            streetStr = @"未知街道";
        }
        
        if ([cityName length] > 0) {
            cityStr = cityName;
        }
        else {
            cityStr = @"未知城市";
        }
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}



#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
    
    MyAnnotationView *annotationView = nil;
    if (annotationView == nil) {
        annotationView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    return annotationView;
}


// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
    NSInteger index = view.tag - 1000;
    NSLog(@"index: %ld",(long)index);
//    NSDictionary *dic = nearbyArray [index];
//    ShopDetailViewController *detailVC = [[ShopDetailViewController alloc] init];
//    detailVC.merchantdataDic = dic;
//    detailVC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:detailVC animated:YES];
}

- (IBAction)routeSearchAction:(id)sender {
    RouteSearchViewController *routeVC = [[RouteSearchViewController alloc] init];
    routeVC.shopDic = self.shopDic;
    routeVC.cityName = cityStr;
    routeVC.streetName = streetStr;
    [self.navigationController pushViewController:routeVC animated:YES];
}

- (IBAction)locationMapAction:(id)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"百度地图", nil];
    action.tag = 200;
    [action showInView:self.view];
}

-(void)viewWillAppear:(BOOL)animated {
    _myMapView.delegate = self;
    _geoCodeSearcher.delegate = self;
    _locService.delegate = self;
    _searcher.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    _myMapView.delegate = nil;
    _geoCodeSearcher.delegate = nil;
    _locService.delegate = nil;
    _searcher.delegate = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 200) {
        if (buttonIndex == 0) {
            [self openBaiduMapRoute];
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
