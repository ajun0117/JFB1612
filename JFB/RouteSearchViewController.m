//
//  RouteSearchViewController.m
//  JFB
//
//  Created by LYD on 15/9/21.
//  Copyright © 2015年 李俊阳. All rights reserved.
//

#import "RouteSearchViewController.h"
#import <BaiduMapAPI/BMapKit.h>//引入所有的头文件
#import "RoutePlanTableViewCell.h"
#import "RouteDeatilViewController.h"

#define RoutePlanCell    @"routePlanTableViewCell"

@interface RouteSearchViewController () <BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate,UIActionSheetDelegate>
{
    MBProgressHUD *_hud;
    MBProgressHUD *_networkConditionHUD;
    BMKLocationService* _locService;
    BMKGeoCodeSearch *_geoCodeSearcher;
    BMKRouteSearch *_searcher;
    NSArray *_routeArray;    //线路数组
    CLLocationCoordinate2D myCoor;
    CLLocationCoordinate2D shopCoor;
    NSString *streetStr;
//    int type; //路线类型 0：公交 1：驾车 2：步行
}

@end

@implementation RouteSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"查看路线";
    
    [self.myTableView registerNib:[UINib nibWithNibName:@"RoutePlanTableViewCell" bundle:nil] forCellReuseIdentifier:RoutePlanCell];
    self.myTableView.tableFooterView = [UIView new];
    
    _locService = [[BMKLocationService alloc]init];
    [_locService startUserLocationService];
    
    //            初始化检索对象
    _geoCodeSearcher = [[BMKGeoCodeSearch alloc]init];
    
    self.mynameL.text = [NSString stringWithFormat:@"我的位置(%@)",self.streetName];
    self.shopNameL.text = self.shopDic [@"merchant_name"];
    //指定起点经纬度
    NSDictionary *myLocation = [[GlobalSetting shareGlobalSettingInstance] myLocation];
    myCoor.latitude = [myLocation [@"latitude"] floatValue];
    myCoor.longitude = [myLocation [@"longitude"] floatValue];
    //商家坐标
    shopCoor.latitude = [self.shopDic [@"latitude"] doubleValue];
    shopCoor.longitude = [self.shopDic [@"longitude"] doubleValue];
    
    
    [self performSelector:@selector(transitRouteAction:) withObject:nil afterDelay:0.5];
//    [self transitRouteAction:nil];
}

-(void)viewWillAppear:(BOOL)animated {
    _locService.delegate = self;
    _geoCodeSearcher.delegate = self;
    _searcher.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    _locService.delegate = nil;
    _geoCodeSearcher.delegate = nil;
    _searcher.delegate = nil;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (! _hud) {
        _hud = [[MBProgressHUD alloc] initWithView:self.view];
        _hud.labelText= @"路线规划中...";
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


#pragma mark - 定位成功代理
//实现相关delegate 处理位置信息更新
//处理方向变更信息
//- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
//{
//    NSLog(@"heading is %@",userLocation.heading);
//}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if (userLocation) {
        [_locService stopUserLocationService];
        [self getReverseGeoCodeWithLocation:userLocation];
        myCoor = userLocation.location.coordinate;
        
        NSString *locationCoordinateStr = [NSString stringWithFormat:@"{\"latitude\":%f,\"longitude\":%f}",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude];
        NSLog(@"locationCoordinateStr: %@",locationCoordinateStr);
        
        //        [_myMapView setCenterCoordinate:userLocation.location.coordinate];
        
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
        if ([streetName length] > 0) {
            streetStr = streetName;
        }
        else {
            streetStr = @"未知街道";
        }
        self.cityName = result.addressDetail.city;
        self.mynameL.text = [NSString stringWithFormat:@"我的位置(%@)",streetStr];
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}


//交换起止点名称和坐标
- (IBAction)exchangeAction:(id)sender {
    NSString *myNameStr = self.mynameL.text;
    NSString *shopNameStr = self.shopNameL.text;
    self.mynameL.text = shopNameStr;
    self.shopNameL.text = myNameStr;
    
    CLLocationCoordinate2D MyCoorTemp = myCoor;
    CLLocationCoordinate2D shopCoorTemp = shopCoor;
    myCoor = shopCoorTemp;
    shopCoor = MyCoorTemp;
    
    if (self.transitRouteBtn.selected) {
        self.transitRouteBtn.selected = NO;
        [self transitRouteAction:nil];
    }
    else if (self.drivingRouteBtn.selected) {
        self.drivingRouteBtn.selected = NO;
        [self drivingRouteAction:nil];
    }
    else if (self.walkingRouteBtn.selected) {
        self.walkingRouteBtn.selected = NO;
        [self walkingRouteAction:nil];
    }
}

- (IBAction)transitRouteAction:(id)sender {

    if (! self.transitRouteBtn.selected) { //当前按钮没有选中时
        [_hud show:YES];
        
        _transitRouteBtn.selected = YES;
        _drivingRouteBtn.selected = NO;
        _walkingRouteBtn.selected = NO;
        
        //初始化检索对象
        _searcher = [[BMKRouteSearch alloc]init];
        _searcher.delegate = self;
        //发起检索
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        start.name = self.mynameL.text;
        start.pt = myCoor;
        
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        end.name = self.shopNameL.text;
        end.pt = shopCoor;
        BMKTransitRoutePlanOption *transitRouteSearchOption = [[BMKTransitRoutePlanOption alloc]init];
        transitRouteSearchOption.city= self.cityName;
        transitRouteSearchOption.from = start;
        transitRouteSearchOption.to = end;
        BOOL flag = [_searcher transitSearch:transitRouteSearchOption];
        
        if(flag)
        {
            NSLog(@"bus检索发送成功");
        }
        else
        {
            NSLog(@"bus检索发送失败");
        }
    }
    
}

- (IBAction)drivingRouteAction:(id)sender {
    if (! self.drivingRouteBtn.selected) { //当前按钮没有选中时
        [_hud show:YES];
        
        _transitRouteBtn.selected = NO;
        _drivingRouteBtn.selected = YES;
        _walkingRouteBtn.selected = NO;
        
        //初始化检索对象
        _searcher = [[BMKRouteSearch alloc]init];
        _searcher.delegate = self;
        //发起检索
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        start.name = self.mynameL.text;
        start.pt = myCoor;
        
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        end.name = self.shopNameL.text;
        end.pt = shopCoor;
        
        BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc]init];
        drivingRouteSearchOption.from = start;
        drivingRouteSearchOption.to = end;
        BOOL flag = [_searcher drivingSearch:drivingRouteSearchOption];
        if(flag)
        {
            NSLog(@"car检索发送成功");
        }
        else
        {
            NSLog(@"car检索发送失败");
        }
    }
}

- (IBAction)walkingRouteAction:(id)sender {
    if (! self.walkingRouteBtn.selected) { //当前按钮没有选中时
        [_hud show:YES];
        
        _transitRouteBtn.selected = NO;
        _drivingRouteBtn.selected = NO;
        _walkingRouteBtn.selected = YES;
        
        //初始化检索对象
        _searcher = [[BMKRouteSearch alloc]init];
        _searcher.delegate = self;
        //发起检索
        BMKPlanNode* start = [[BMKPlanNode alloc]init];
        start.name = self.mynameL.text;
        start.pt = myCoor;
        
        BMKPlanNode* end = [[BMKPlanNode alloc]init];
        end.name = self.shopNameL.text;
        end.pt = shopCoor;
        
        BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc]init];
        walkingRouteSearchOption.from = start;
        walkingRouteSearchOption.to = end;
        BOOL flag = [_searcher walkingSearch:walkingRouteSearchOption];
        if(flag)
        {
            NSLog(@"walk检索发送成功");
        }
        else
        {
            NSLog(@"walk检索发送失败");
        }
    }
}

#pragma mark - 实现Deleage处理回调结果
-(void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    [_hud hide:YES];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        _routeArray = result.routes;
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        //当路线起终点有歧义时通，获取建议检索起终点
        //result.routeAddrResult
        _routeArray = @[];
        
        _networkConditionHUD.labelText = @"起终点有歧义！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    else {
        _routeArray = @[];
        _networkConditionHUD.labelText = @"未找到公交线路！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    
    [self.myTableView reloadData];
}


- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    [_hud hide:YES];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        _routeArray = result.routes;
    }
    else {
        _routeArray = @[];
        _networkConditionHUD.labelText = @"未找到驾车线路！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    
    [self.myTableView reloadData];
}


- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    [_hud hide:YES];
    
    if (error == BMK_SEARCH_NO_ERROR) {
        _routeArray = result.routes;
    }
    else {
        _routeArray = @[];
        _networkConditionHUD.labelText = @"未找到步行线路！";
        [_networkConditionHUD show:YES];
        [_networkConditionHUD hide:YES afterDelay:HUDDelay];
    }
    
    [self.myTableView reloadData];
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_routeArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
//    NSLog(@"%f",cell.bounds.size.height);
    return 55;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    if (self.drivingRouteBtn.selected) {
//        return 70;
//    }
//    return 0;
//}


//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    if (self.drivingRouteBtn.selected) {
//        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 55)];
//        view.backgroundColor = [UIColor clearColor];
//        
//        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn.frame = CGRectMake((SCREEN_WIDTH-150)/2, 30, 150, 40);
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn setTitle:@"使用本机地图导航" forState:UIControlStateNormal];
//        btn.titleLabel.font = [UIFont systemFontOfSize:15];
//        [btn addTarget:self action:@selector(daohang) forControlEvents:UIControlEventTouchUpInside];
//        btn.layer.borderColor = Cell_sepLineColor.CGColor;
//        btn.layer.borderWidth = 1;
//        [view addSubview:btn];
//        
//        return view;
//    }
//    return nil;
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    RoutePlanTableViewCell *cell = (RoutePlanTableViewCell *)[tableView dequeueReusableCellWithIdentifier:RoutePlanCell];
    
    if (self.transitRouteBtn.selected) {
        //公交
        BMKTransitRouteLine* plan = (BMKTransitRouteLine*)_routeArray [indexPath.row];
        // 计算路线方案中的路段数目
        int size = (int)[plan.steps count];
        
        NSString *vehicleName = @"";
        for (int i = 0; i < size; ++i) {
            BMKTransitStep* transitStep = [plan.steps objectAtIndex:i];
            BMKVehicleInfo *infos = transitStep.vehicleInfo;
            NSLog(@"infos: %@",infos);
            //判断是否有线路名称
            if (infos) {
                if ([vehicleName isEqualToString:@""]) {
                    vehicleName = [NSString stringWithFormat:@"%@",infos.title];
                }
                else{
                    vehicleName = [NSString stringWithFormat:@"%@ - %@",vehicleName,infos.title];
                }
            }
        }
        cell.numberL.text = [NSString stringWithFormat:@"0%i",indexPath.row+1];
        cell.routeNameL.text = vehicleName;
        
        NSString *timeStr = [self durationWithBMKRouteLine:plan];
        
        NSString *distance = [NSString stringWithFormat:@"%.1f公里",plan.distance / 1000.0];
        
        cell.routeDetailL.text = [NSString stringWithFormat:@"%@  |  %@",timeStr,distance];
        return cell;
    }
    
    else if (self.drivingRouteBtn.selected) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)_routeArray [indexPath.row];
        
//        int size = (int)[plan.steps count];
        
//        for (int i = 0; i < size; ++i) {
//            BMKDrivingStep* drivingStep = [plan.steps objectAtIndex:i];
//            NSString *exitIns = drivingStep.exitInstruction;
//            //            NSLog(@"exitIns: %@",exitIns);
//            NSLog(@"instruction: %@",drivingStep.instruction);
//            NSLog(@"exit.title: %@",drivingStep.exit.title);
//            //判断是否有线路名称
//        }
        
//        if (size > 0) {
            BMKDrivingStep* drivingStep = [plan.steps firstObject];
            NSString *Instr = drivingStep.instruction;
            
            cell.numberL.text = [NSString stringWithFormat:@"0%i",indexPath.row+1];
            cell.routeNameL.text = Instr;
            
            NSString *timeStr = [self durationWithBMKRouteLine:plan];
            
            NSString *distance = [NSString stringWithFormat:@"%.1f公里",plan.distance / 1000.0];
            
            cell.routeDetailL.text = [NSString stringWithFormat:@"%@  |  %@",timeStr,distance];
            
            return cell;
//        }
//        else {
//            return nil;
//        }
    }
    
    else if (self.walkingRouteBtn.selected) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)_routeArray [indexPath.row];
        BMKWalkingStep* walkingStep = [plan.steps firstObject];
        NSString *Instr = walkingStep.instruction;
        
        cell.numberL.text = [NSString stringWithFormat:@"0%i",indexPath.row+1];
        cell.routeNameL.text = Instr;
        
        NSString *timeStr = [self durationWithBMKRouteLine:plan];
        
        NSString *distance = [NSString stringWithFormat:@"%.1f公里",plan.distance / 1000.0];
        
        cell.routeDetailL.text = [NSString stringWithFormat:@"%@  |  %@",timeStr,distance];
        
        return cell;
    }
    
    else {
        return nil;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    RouteDeatilViewController *detailVC = [[RouteDeatilViewController alloc] init];
    RoutePlanTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    detailVC.routName = cell.routeNameL.text;
    detailVC.routTime = cell.routeDetailL.text;
    
    if (_transitRouteBtn.selected) {
        BMKTransitRouteLine* plan = (BMKTransitRouteLine*)_routeArray [indexPath.row];
        detailVC.transitPlan = plan;
        detailVC.drivingPlan = nil;
        detailVC.walkingPlan = nil;
    }
    else if (_drivingRouteBtn.selected) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)_routeArray [indexPath.row];
        detailVC.drivingPlan = plan;
        detailVC.transitPlan = nil;
        detailVC.walkingPlan = nil;
    }
    else if (_walkingRouteBtn.selected) {
        BMKWalkingRouteLine* plan = (BMKWalkingRouteLine*)_routeArray [indexPath.row];
        detailVC.walkingPlan = plan;
        detailVC.transitPlan = nil;
        detailVC.drivingPlan = nil;
    }
    [self.navigationController pushViewController:detailVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSString *)durationWithBMKRouteLine:(BMKRouteLine *)plan {
    BMKTime* durati = plan.duration;
    int date = durati.dates;
    int hour = durati.hours;
    int minute = durati.minutes;
    int second = durati.seconds;
    NSString *timeStr = @"";
    if (date > 0) {
        timeStr = [NSString stringWithFormat:@"%d天",date];
    }
    if (hour > 0) {
        if ([timeStr isEqualToString:@""]) {
            timeStr = [NSString stringWithFormat:@"%d小时",hour];
        }
        else{
            timeStr = [NSString stringWithFormat:@"%@%d小时",timeStr,hour];
        }
    }
    if (minute > 0) {
        if ([timeStr isEqualToString:@""]) {
            timeStr = [NSString stringWithFormat:@"%d分钟",minute];
        }
        else{
            timeStr = [NSString stringWithFormat:@"%@%d分钟",timeStr,minute];
        }
    }
    if (second > 0) {
        if ([timeStr isEqualToString:@""]) {
            timeStr = [NSString stringWithFormat:@"%d秒",second];
        }
        //            else{
        //                timeStr = [NSString stringWithFormat:@"%@%d秒",timeStr,second];
        //            }
    }
    return timeStr;
}

-(void)daohang {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:@"提示" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"百度地图" otherButtonTitles:nil, nil];
    action.tag = 200;
    [action showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (actionSheet.tag == 200) {
        if (buttonIndex == 0) {
//            [self openBaiduMapRoute];
        }
    }
}

#pragma mark - 打开手机地图导航
//-(void)openBaiduMapRoute {
//    //打开地图驾车路线检索
//    BMKOpenDrivingRouteOption *opt = [[BMKOpenDrivingRouteOption alloc] init];
//    opt.appScheme = @"baidumapJFB";//用于调起成功后，返回原应用
//    //初始化起点节点
//    BMKPlanNode* start = [[BMKPlanNode alloc]init];
//    //指定起点经纬度
//    CLLocationCoordinate2D myCoor;
//    NSDictionary *myLocation = [[GlobalSetting shareGlobalSettingInstance] myLocation];
//    myCoor.latitude = [myLocation [@"latitude"] floatValue];
//    myCoor.longitude = [myLocation [@"longitude"] floatValue];
//    //指定起点名称
//    start.name = @"我的位置";
//    start.pt = myCoor;
//    //指定起点
//    opt.startPoint = start;
//    
//    
//    //初始化终点节点
//    BMKPlanNode* end = [[BMKPlanNode alloc]init];
//    //商家坐标
//    CLLocationCoordinate2D coor;
//    coor.latitude = [self.shopDic [@"latitude"] doubleValue];
//    coor.longitude = [self.shopDic [@"longitude"] doubleValue];
//    end.pt = coor;
//    //指定终点名称
//    end.name = self.shopDic [@"merchant_name"];
//    opt.endPoint = end;
//    
//    BMKOpenErrorCode code = [BMKOpenRoute openBaiduMapDrivingRoute:opt];
//    if(code == BMK_OPEN_NO_ERROR)
//    {
//        NSLog(@"成功");
//    }
//    else
//    {
//        NSLog(@"失败");
//    }
//    
//}

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
