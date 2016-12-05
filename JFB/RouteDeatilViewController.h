//
//  RouteDeatilViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/9/21.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>//引入所有的头文件

@interface RouteDeatilViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *routeTimeL;
@property (weak, nonatomic) IBOutlet UILabel *routeNameL;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) BMKTransitRouteLine *transitPlan;
@property (strong, nonatomic) BMKDrivingRouteLine *drivingPlan;
@property (strong, nonatomic) BMKWalkingRouteLine *walkingPlan;

@property (strong, nonatomic) NSString *routName;
@property (strong, nonatomic) NSString *routTime;

@end
