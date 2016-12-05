//
//  RouteSearchViewController.h
//  JFB
//
//  Created by LYD on 15/9/21.
//  Copyright © 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteSearchViewController : UIViewController

@property (strong, nonatomic) NSDictionary *shopDic;
@property (strong, nonatomic) NSString *cityName;
@property (strong, nonatomic) NSString *streetName;

@property (weak, nonatomic) IBOutlet UILabel *shopNameL;
@property (weak, nonatomic) IBOutlet UILabel *mynameL;
@property (weak, nonatomic) IBOutlet UIButton *transitRouteBtn;
@property (weak, nonatomic) IBOutlet UIButton *drivingRouteBtn;
@property (weak, nonatomic) IBOutlet UIButton *walkingRouteBtn;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end
