//
//  GoodsDetailViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsDetailViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) NSString *goods_id;
@property (strong, nonatomic) NSString *merchant_id;

@end
