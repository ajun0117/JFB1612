//
//  AllEvaluateViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/9/5.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AllEvaluateViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) NSString *merchant_id;
@property (strong, nonatomic) NSString *goods_id;

@end
