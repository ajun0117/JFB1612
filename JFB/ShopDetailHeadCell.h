//
//  ShopDetailHeadCell.h
//  JFB
//
//  Created by LYD on 15/9/2.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJQRateView.h"

@interface ShopDetailHeadCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *bigIM;
@property (weak, nonatomic) IBOutlet UILabel *shopNameL;
@property (weak, nonatomic) IBOutlet DJQRateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *scoreL;
@property (weak, nonatomic) IBOutlet UILabel *fractionL;
@property (weak, nonatomic) IBOutlet UIButton *imgsBtn;

@end
