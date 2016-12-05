//
//  HomeShopListCell.h
//  JFB
//
//  Created by LYD on 15/8/18.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DJQRateView.h"

@interface HomeShopListCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *shopIM;
@property (weak, nonatomic) IBOutlet UILabel *shopNameL;
@property (weak, nonatomic) IBOutlet UILabel *shopAddressL;
@property (weak, nonatomic) IBOutlet DJQRateView *rateView;
@property (weak, nonatomic) IBOutlet UILabel *scoreL;
@property (weak, nonatomic) IBOutlet UILabel *integralRateL;
@property (weak, nonatomic) IBOutlet UILabel *distanceL;

@end
