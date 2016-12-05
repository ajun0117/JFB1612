//
//  ShopDetailVoucherCell.h
//  JFB
//
//  Created by 李俊阳 on 15/9/2.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StrikeThroughLabel.h"

@interface ShopDetailVoucherCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *emptyL;
@property (weak, nonatomic) IBOutlet UIView *voucherView;
@property (weak, nonatomic) IBOutlet UIImageView *voucherIM;
@property (weak, nonatomic) IBOutlet UILabel *nameL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;
@property (weak, nonatomic) IBOutlet StrikeThroughLabel *costPriceStrikeL;
@property (weak, nonatomic) IBOutlet UILabel *saleL;

@property (weak, nonatomic) IBOutlet UILabel *collectionSaleL;
@end
