//
//  GoodsDetailHeadCell.h
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrikeThroughLabel.h"

@interface GoodsDetailHeadCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *bigIM;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameL;
@property (weak, nonatomic) IBOutlet UILabel *goodsIntroduceL;

@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (weak, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL;
@property (weak, nonatomic) IBOutlet UIButton *buyBtn;
@property (weak, nonatomic) IBOutlet UIButton *promiseBtn;
@property (weak, nonatomic) IBOutlet UILabel *saleL;

@end
