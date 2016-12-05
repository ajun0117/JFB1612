//
//  CitySelectViewController.m
//  JFB
//
//  Created by LYD on 15/8/28.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "CitySelectViewController.h"
#import <BaiduMapAPI/BMapKit.h>
#import "AppDelegate.h"

@interface CitySelectViewController () <BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
    BMKLocationService* _locService;
    BMKGeoCodeSearch *_searcher;
    NSMutableArray *keyArrays;
    NSString *locationCityName;
    NSMutableDictionary *chongzuDic;
}

@end

@implementation CitySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择城市";
    
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    NSArray *levelAry = [app selectDataWithLevel:@"2"];  //库中读取所有城市数组
    
    [self chongzuDictionaryWithArray:levelAry];
    
    keyArrays = [[NSMutableArray alloc] initWithObjects:@"定位", nil];
    [keyArrays addObjectsFromArray:[[chongzuDic allKeys] sortedArrayUsingSelector:@selector(compare:)]];
    
    _locService = [[BMKLocationService alloc]init];
    
    //            初始化检索对象
    _searcher = [[BMKGeoCodeSearch alloc]init];
    
    
    /*********** 如果定位城市没有开通，则必须选择一个已开通城市 ************/
    if (_isMustSelect) {
        self.navigationItem.hidesBackButton =YES;
    }
    
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_locService startUserLocationService];
}

#pragma mark - 重新组合城市数据
-(void)chongzuDictionaryWithArray:(NSArray *)ary {
    NSMutableSet *set = [NSMutableSet set];
    for (CityDistrictsCoreObject *cityObject in ary) {
        //取出拼音首字母
        NSString *coding = [[cityObject.pyName substringToIndex:1] uppercaseString];
        [set addObject:coding];
    }
    //重组字典
    NSArray *arr = [[set allObjects] sortedArrayUsingSelector:@selector(compare:)];
    chongzuDic = [NSMutableDictionary dictionary];
    for (NSString *key in arr) {
        NSMutableArray *newArray = [NSMutableArray array];
        for (CityDistrictsCoreObject *cityObjectt in ary) {
            NSString *coding = [[cityObjectt.pyName substringToIndex:1] uppercaseString];
            if ([coding isEqualToString:key]) {
                [newArray addObject:cityObjectt];
            }
        }
        [chongzuDic setObject:newArray forKey:key];
    }
//    NSLog(@"chongzuDic: %@",chongzuDic);
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
    
    NSLog(@"error is %@",[error description]);
    UITableViewCell *cell = [self.citytableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    cell.textLabel.text = @"定位失败，点击重新定位";
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    if (userLocation)
    {
        [_locService stopUserLocationService];
        [self getReverseGeoCodeWithLocation:userLocation];
    }
}

-(void)getReverseGeoCodeWithLocation:(BMKUserLocation *)userLocation
{
    //            发起反向地理编码检索
    CLLocationCoordinate2D pt = userLocation.location.coordinate;
    NSLog(@"%lf,%lf",pt.latitude,pt.longitude);
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
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
        NSString *cityName = result.addressDetail.city;
        if ([cityName length] > 0) {
            locationCityName = cityName;
//            locationCityName = @"广州";
        }
        else {
            locationCityName = @"超出定位解析范围";
        }
        
        [self.citytableView reloadData];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"获取城市信息失败" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma makr  - UITableView Datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [keyArrays count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"";
    }
    
    return [keyArrays objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    
    NSArray *cityArr = [chongzuDic objectForKey:[keyArrays objectAtIndex:section]];
    return cityArr.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return keyArrays;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    
    if (indexPath.section == 0) {
        UILabel *cityL = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 12, 60, 20)];
        cityL.tag = 100;
        cityL.textColor = [UIColor redColor];
        [cell.contentView addSubview:cityL];
        if (! locationCityName) {
            cell.textLabel.text = @"正在定位...";
            cityL.hidden = YES;
            cityL.text = @"";
        }
        else {
            cell.textLabel.text = @"当前定位城市:";
            cityL.hidden = NO;
            cityL.text = locationCityName;
        }
        
//        if (self.cityLocationStatus == CityLocationForIng) {
//            cell.textLabel.text = @"正在查找...";
//        } else if (self.cityLocationStatus == CityLocationForSuccussWithCityInfo) {
//            cell.textLabel.text = [NSString stringWithFormat:@"%@",self.cityInfo.cityName];
//        } else if (self.cityLocationStatus == CityLocationForSuccussWithoutCityInfo) {
//            cell.textLabel.text = @"你不在当前城市列表";
//        } else if (self.cityLocationStatus == CityLocationForFailForNoPermission) {
//            cell.textLabel.text = @"请打开地理位置权限";
//        } else if (self.cityLocationStatus == CityLocationForFailForNoNet) {
//            cell.textLabel.text = @"定位失败，请重试";
//        } else if (self.cityLocationStatus == CityLocationForFailForGps) {
//            cell.textLabel.text = @"定位失败，请重试";
//        }
    } else {
//        NSArray *cityArr = [self.citysDic objectForKey:[keyArrays objectAtIndex:indexPath.section]];
//        CityObject *cityInfo = (CityObject *)[cityArr objectAtIndex:indexPath.row];
//        cell.textLabel.text = cityInfo.areaName;
//    cell.textLabel.text = @"测试";
        
        NSArray *cityArr = [chongzuDic objectForKey:[keyArrays objectAtIndex:indexPath.section]];
        CityDistrictsCoreObject *cityInfo = (CityDistrictsCoreObject *)[cityArr objectAtIndex:indexPath.row];
        cell.textLabel.text = cityInfo.areaName;
        BOOL isOpen = [cityInfo.isopen boolValue];
        if (isOpen) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        else {
            cell.textLabel.textColor = [UIColor grayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }
    
    return cell;
}


#pragma makr  - UITableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        if ([cell.textLabel.text isEqual:@"定位失败，点击重新定位"]) {
            [_locService startUserLocationService];
        }
        else {
//            UILabel *cityL = (UILabel *)[cell viewWithTag:100];
//            NSString *cityName = cityL.text;
            
            /*********** 如果定位城市没有开通，则必须选择一个已开通城市 ************/
//            if (_isMustSelect) {
//                NSString *msgStr = [NSString stringWithFormat:@"您当前定位的城市为【%@】暂未开通！请选择其他城市！",locationCityName];
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
//                [alert show];
//                return;
//            }
            
            BOOL isOpen = NO;
            NSArray *objectArrays = [chongzuDic allValues];
            for (NSArray *arr in objectArrays) {
                for (CityDistrictsCoreObject *cityInfo in arr) {
                    if ([cityInfo.areaName isEqual:locationCityName]) {
                        if ([cityInfo.isopen boolValue]) {
                            isOpen = YES;
                            [self.selectDelegate alreadySelectCity:cityInfo];
                            [self.navigationController popViewControllerAnimated:YES];
                            return;
                        }
                    }
                }
            }
            if (isOpen == NO) {
//                NSString *msgStr = [NSString stringWithFormat:@"您当前定位的城市为【%@】暂未开通！请选择其他城市！",locationCityName];
                NSString *msgStr = [NSString stringWithFormat:@"您当前定位的城市暂未开放，请选择其他城市！"];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:msgStr delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alert show];
                return;
            }
        }
    }
    else {
        NSArray *cityArr = [chongzuDic objectForKey:[keyArrays objectAtIndex:indexPath.section]];
        CityDistrictsCoreObject *cityInfo = (CityDistrictsCoreObject *)[cityArr objectAtIndex:indexPath.row];
        if ([cityInfo.isopen boolValue]) {  //已开放的可点击
            [self.selectDelegate alreadySelectCity:cityInfo];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    
}



-(void)viewWillAppear:(BOOL)animated {
    _locService.delegate = self;
    _searcher.delegate = self;
}

-(void)viewWillDisappear:(BOOL)animated {
    _searcher.delegate = nil;
    _locService.delegate = nil;
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
