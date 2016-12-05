//
//  HomeViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/8/14.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI/BMapKit.h>//引入所有的头文件

@interface HomeViewController : UIViewController <UISearchBarDelegate,UIScrollViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>


@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (weak, nonatomic) IBOutlet UIView *citySelectBgView;
@property (weak, nonatomic) IBOutlet UIView *citySelectView;
@property (weak, nonatomic) IBOutlet UICollectionView *cityCollectionView;
@property (weak, nonatomic) IBOutlet UIView *changeCityView;
@property (weak, nonatomic) IBOutlet UILabel *currentCityL;

@end
