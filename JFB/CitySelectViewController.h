//
//  CitySelectViewController.h
//  JFB
//
//  Created by LYD on 15/8/28.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CityObject.h"
#import "CityDistrictsCoreObject.h"

@protocol   AlreadySelectCityDelegate    <NSObject>

-(void)alreadySelectCity:(CityDistrictsCoreObject *)city;

@end


@interface CitySelectViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *citytableView;
//@property (strong, nonatomic) NSMutableDictionary *citysDic;
@property (assign, nonatomic) id <AlreadySelectCityDelegate> selectDelegate;

@property (assign, nonatomic) BOOL isMustSelect; //是否必须选择一个城市
@end
