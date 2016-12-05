//
//  ShopDetailHeadCell.m
//  JFB
//
//  Created by LYD on 15/9/2.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import "ShopDetailHeadCell.h"

@implementation ShopDetailHeadCell

- (void)awakeFromNib {
    // Initialization code
    self.imgsBtn.layer.borderWidth = 1;
    self.imgsBtn.layer.borderColor = [UIColor whiteColor].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
