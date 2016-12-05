//
//  OrderRefundViewController.h
//  JFB
//
//  Created by LYD on 15/9/25.
//  Copyright © 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderRefundViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (strong, nonatomic) NSString *coupon_no;
@property (strong, nonatomic) NSString *order_no;
@property (strong, nonatomic) NSString *refund_amount;
@property (strong, nonatomic) NSDictionary *goodsDic;
@property (strong, nonatomic) NSArray *couponArray; //所有代金券数组
@end
