//
//  ShopMapNavigationViewController.h
//  JFB
//
//  Created by LYD on 15/9/17.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>//引入所有的头文件

@interface ShopMapNavigationViewController : UIViewController <BMKLocationServiceDelegate,BMKMapViewDelegate>

//@property (nonatomic, strong) NSString *latitudeStr;
//@property (nonatomic, strong) NSString *longitudeStr;
@property (nonatomic, strong) NSDictionary *shopDic;

@property (weak, nonatomic) IBOutlet UILabel *shopNameL;
@property (weak, nonatomic) IBOutlet UILabel *shopAddressL;
@property (weak, nonatomic) IBOutlet UIButton *routeSearchBtn;
@property (weak, nonatomic) IBOutlet UIButton *locationmapBtn;

@end
