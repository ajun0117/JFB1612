//
//  MyPensionsViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyPensionsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *totalIncomeBtn;
@property (weak, nonatomic) IBOutlet UILabel *totalIncomeL;
@property (weak, nonatomic) IBOutlet UIView *totalIncomeView;
@property (weak, nonatomic) IBOutlet UIButton *infobtn;
@property (weak, nonatomic) IBOutlet UIView *infoView;

@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UILabel *danweiL;
@property (weak, nonatomic) IBOutlet UIView *LookInfoView;
@property (weak, nonatomic) IBOutlet UITextField *startDateTF;
@property (weak, nonatomic) IBOutlet UITextField *endDateTF;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end
