//
//  ShopDetailAddressCell.h
//  JFB
//
//  Created by LYD on 15/9/2.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShopDetailAddressCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *addressL;
@property (weak, nonatomic) IBOutlet UIButton *mapAddressBtn;
@property (weak, nonatomic) IBOutlet UIButton *phoneBtn;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *phoneViewWidthCons;

@end
