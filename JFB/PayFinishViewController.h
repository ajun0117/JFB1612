//
//  PayFinishViewController.h
//  JFB
//
//  Created by LYD on 15/9/23.
//  Copyright © 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayFinishViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *orderNumberL;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameL;

@property (weak, nonatomic) IBOutlet UILabel *couponNumL;
@property (weak, nonatomic) IBOutlet UITableView *couponTableView;

@property (strong, nonatomic) NSDictionary *finishDic;

@end
