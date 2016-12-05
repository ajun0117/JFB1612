//
//  QRcodeViewController.h
//  JFB
//
//  Created by LYD on 15/8/24.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QRcodeViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *QRimageView;
@property (strong, nonatomic) NSString *qrString;
@property (strong, nonatomic) NSString *titleStr;
@end
