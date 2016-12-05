//
//  OrderCouponTableViewCell.h
//  JFB
//
//  Created by LYD on 15/9/25.
//  Copyright © 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderCouponTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *effective_dateL;
@property (weak, nonatomic) IBOutlet UIButton *dobtn;
@property (weak, nonatomic) IBOutlet UIButton *consume_codeBtn;
@property (weak, nonatomic) IBOutlet UILabel *statusL;
@end
