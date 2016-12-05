//
//  PayOrderViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PayOrderViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *orderNumberL;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameL;
@property (weak, nonatomic) IBOutlet UILabel *allPriceL;
@property (weak, nonatomic) IBOutlet UIButton *alipayBtn;
@property (weak, nonatomic) IBOutlet UIButton *weixinpayBtn;

@property (strong, nonatomic) NSDictionary *orderInfoDic;
@property (strong, nonatomic) NSString *goods_name;
@property (strong, nonatomic) NSString *goods_detail;
@property (strong, nonatomic) NSString *amount;
@property (strong, nonatomic) NSString *their_type;
@property (strong, nonatomic) NSString *merchant_id;
@property (strong, nonatomic) NSString *qtyStr;

@end
