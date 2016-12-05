//
//  OrderDetailHeaderCell.h
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *goodsIM;
@property (weak, nonatomic) IBOutlet UILabel *goodsNameL;
@property (weak, nonatomic) IBOutlet UILabel *goodsIntroduceL;
@property (weak, nonatomic) IBOutlet UILabel *priceL;

@end
