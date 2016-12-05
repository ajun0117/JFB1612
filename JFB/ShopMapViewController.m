//
//  ShopMapViewController.m
//  JFB
//
//  Created by 李俊阳 on 15/8/29.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "ShopMapViewController.h"
#import "MyAnnotationView.h"
#import "ShopDetailViewController.h"

static NSString *AnnotationViewID = @"MyAnnotation";

@interface ShopMapViewController ()
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    BMKMapView *_myMapView;
    BMKLocationService* _locService;
    NSArray *nearbyArray; //附近商户列表数据
    NSInteger annoTag;
}


@end

@implementation ShopMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商家地图";
    
    _myMapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - 64)];
    [self.view addSubview:_myMapView];
//    [_myMapView showsUserLocation];
    
    _hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:_hud];
    
    _locService = [[BMKLocationService alloc]init];
    [_locService startUserLocationService];
    
    //初始化显示上次存储的用户位置
    NSDictionary *location = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    CLLocationCoordinate2D coor;
    coor.latitude = [location [@"latitude"] doubleValue];
    coor.longitude = [location [@"longitude"] doubleValue];
    [_myMapView setCenterCoordinate:coor];
    [_myMapView setZoomLevel:15];
    
}

//-(void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    for (int i = 0; i < 3; ++i) {
//        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
//        
//        //初始化显示上次存储的用户位置
//        NSDictionary *location = [[GlobalSetting shareGlobalSettingInstance] myLocation];
//        CLLocationCoordinate2D coor;
//        coor.latitude = [location [@"latitude"] doubleValue] + 0.01 * i;
//        coor.longitude = [location [@"longitude"] doubleValue] + 0.01 * i;
//        annotation.coordinate = coor;
//        //            annotation.tag = i + 1000; //tag值一用于区分不同的annotation
//        annoTag = i + 1000;
//        annotation.title = [NSString stringWithFormat:@"ceshi %ld",annoTag];
//        [_myMapView addAnnotation:annotation];
//    }
//}


#pragma mark - 定位成功代理
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
        
        NSString *locationCoordinateStr = [NSString stringWithFormat:@"{\"latitude\":%f,\"longitude\":%f}",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
        NSLog(@"locationCoordinateStr: %@",locationCoordinateStr);
        
        [_myMapView setCenterCoordinate:userLocation.location.coordinate];
        
        NSString *lat = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
        NSString *lon = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
        NSDictionary *locationDic = [NSDictionary dictionaryWithObjectsAndKeys:lat,@"latitude",lon,@"longitude", nil];
        //存储当前位置坐标
        [[GlobalSetting shareGlobalSettingInstance] setMyLocationWithDic:locationDic];
        
        [self requestGetMapNearbyShopListWithLocationDic:locationDic];
        
    }
}

#pragma mark - BMKMapViewDelegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation {
//    BMKAnnotationView *view = [[BMKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:nil];
//    return view;
//    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
//        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
//        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
//        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
//        return newAnnotationView;
//    }
//    return nil;
    
    //动画annotation
    
    MyAnnotationView *annotationView = nil;
    if (annotationView == nil) {
        annotationView = [[MyAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    }
    annotationView.tag = annoTag;   //设置标注点View的tag
    return annotationView;
}


// 当点击annotation view弹出的泡泡时，调用此接口
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view;
{
    NSLog(@"paopaoclick");
    NSInteger index = view.tag - 1000;
    NSLog(@"index: %ld",(long)index);
    NSDictionary *dic = nearbyArray [index];
    ShopDetailViewController *detailVC = [[ShopDetailViewController alloc] init];
    detailVC.merchantdataDic = dic;
    [self.navigationController pushViewController:detailVC animated:YES];
}


-(void)viewWillAppear:(BOOL)animated {
    _myMapView.delegate = self;
    _locService.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    _myMapView.delegate = nil;
    _locService.delegate = nil;
}

#pragma mark - 发送请求
-(void)requestGetMapNearbyShopListWithLocationDic:(NSDictionary *)dic { //获取地图附近商户列表
    [_hud show:YES];
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishedRequestData:) name:GetAnnexMerchantList object:nil];
    
    NSDictionary *infoDic = [[NSDictionary alloc] initWithObjectsAndKeys:GetAnnexMerchantList, @"op", nil];
    NSDictionary *pram = [[NSDictionary alloc] initWithObjectsAndKeys:[dic objectForKey:@"latitude"],@"latitude",[dic objectForKey:@"longitude"],@"longitude", nil];
    [[DataRequest sharedDataRequest] postDataWithUrl:RequestURL(GetAnnexMerchantList) delegate:nil params:pram info:infoDic];
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
    
    if ([notification.name isEqualToString:GetAnnexMerchantList]) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:GetAnnexMerchantList object:nil];

        NSLog(@"GetMerchantList_responseObject: %@",responseObject);
        
        if ([responseObject[@"status"] boolValue]) {
//            _networkConditionHUD.labelText = [responseObject objectForKey:MSG];
//            [_networkConditionHUD show:YES];
//            [_networkConditionHUD hide:YES afterDelay:HUDDelay];
            
            nearbyArray = responseObject[DATA];
            
            for (int i = 0; i < [nearbyArray count]; ++i) {
                NSDictionary *dic = nearbyArray [i];
                // 添加一个PointAnnotation
                BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
                
                CLLocationCoordinate2D coor;
                coor.latitude = [dic [@"latitude"] doubleValue];
                coor.longitude = [dic [@"longitude"] doubleValue];
                annotation.coordinate = coor;
//                annotation.tag = i + 1000; //tag值一用于区分不同的annotation
                annoTag = i + 1000;
                annotation.title = dic [@"merchant_name"];
                [_myMapView addAnnotation:annotation];
            }
            
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
