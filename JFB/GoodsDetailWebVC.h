//
//  GoodsDetailWebVC.h
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrikeThroughLabel.h"

@interface GoodsDetailWebVC : UIViewController

@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (weak, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL;

@property (retain, nonatomic) NSString *webUrlStr; //Web加载的地址
@property (strong, nonatomic) NSDictionary *goodsDic; //商品详情数据字典
@property (strong, nonatomic) NSString *merchant_id; //商户id

@end
