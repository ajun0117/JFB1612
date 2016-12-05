//
//  MineViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/8/19.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MineViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

//@property (weak, nonatomic) IBOutlet UIView *headView;
//@property (weak, nonatomic) IBOutlet UIImageView *headIM;
//@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (retain, nonatomic) UIView *headView;
@property (retain, nonatomic) UIImageView *headIM;
@property (retain, nonatomic) UITableView *myTableView;

@end
