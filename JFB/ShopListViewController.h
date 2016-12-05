//
//  ShopListViewController.h
//  JFB
//
//  Created by LYD on 15/9/1.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopListViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *typeBtn;
@property (weak, nonatomic) IBOutlet UIButton *countyBtn;
@property (weak, nonatomic) IBOutlet UIButton *orderBtn;
@property (weak, nonatomic) IBOutlet UILabel *locationL;
@property (weak, nonatomic) IBOutlet UIButton *refreshBtn;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (weak, nonatomic) IBOutlet UIView *selectBgView;
@property (weak, nonatomic) IBOutlet UITableView *selectTableView;

@property (strong, nonatomic) NSString *menu_subtitle;
@property (strong, nonatomic) NSString *menu_code;
@property (strong, nonatomic) NSString *typeID;

@end
