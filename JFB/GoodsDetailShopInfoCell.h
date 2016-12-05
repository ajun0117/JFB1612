//
//  GoodsDetailShopInfoCell.h
//  JFB
//
//  Created by 李俊阳 on 15/9/4.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GoodsDetailShopInfoCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *shopsNameL;
@property (weak, nonatomic) IBOutlet UILabel *shopAddressL;
@property (weak, nonatomic) IBOutlet UILabel *distanceL;
@property (weak, nonatomic) IBOutlet UIButton *mapAddressBtn;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;

@end
