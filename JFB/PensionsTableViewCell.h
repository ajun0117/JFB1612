//
//  PensionsTableViewCell.h
//  JFB
//
//  Created by 李俊阳 on 15/9/20.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PensionsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *oNameL;
@property (weak, nonatomic) IBOutlet UILabel *dealtimeL;
@property (weak, nonatomic) IBOutlet UILabel *ratioL; 
@property (weak, nonatomic) IBOutlet UILabel *dealMnyL;
@property (weak, nonatomic) IBOutlet UILabel *pointL;

@end
