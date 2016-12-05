//
//  SubmitOrderViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubmitOrderViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *goodsNameL;
@property (weak, nonatomic) IBOutlet UILabel *singlePriceL;
@property (weak, nonatomic) IBOutlet UITextField *numberTF;
@property (weak, nonatomic) IBOutlet UIButton *decBtn;
@property (weak, nonatomic) IBOutlet UIButton *incBtn;
@property (weak, nonatomic) IBOutlet UILabel *allPriceL;
@property (weak, nonatomic) IBOutlet UILabel *phoneL;

@property (strong, nonatomic) NSString *merchant_id;
@property (strong, nonatomic) NSDictionary *goodsdataDic;
@property (strong, nonatomic) NSString *order_no;

@end
