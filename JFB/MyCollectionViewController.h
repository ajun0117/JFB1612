//
//  MyCollectionViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyCollectionViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *goodsBtn;
@property (weak, nonatomic) IBOutlet UIView *goodsView;
@property (weak, nonatomic) IBOutlet UIButton *shopBtn;
@property (weak, nonatomic) IBOutlet UIView *shopView;

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@end
