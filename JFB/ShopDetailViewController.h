//
//  ShopDetailViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/8/29.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopDetailViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *nearbyHeadView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn1;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn2;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn3;
@property (weak, nonatomic) IBOutlet UIButton *typeBtn4;

//@property (strong, nonatomic) NSString *merchant_id;
//@property (strong, nonatomic) NSString *logoIMStr;
//@property (strong, nonatomic) NSString *backgroundIMStr;
//@property (assign, nonatomic) int picturecount;

@property (strong, nonatomic) NSDictionary *merchantdataDic;  //商户信息数据字典

@end
