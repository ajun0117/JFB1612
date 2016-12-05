//
//  MemberCardViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/8/23.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberCardViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *cardNumTF;
@property (weak, nonatomic) IBOutlet UITextField *codeTF;
@property (weak, nonatomic) IBOutlet UIButton *confireBtn;
@property (assign, nonatomic) BOOL isChangeCard; //是否修改会员卡，false表示绑定会员卡
@property (weak, nonatomic) IBOutlet UIView *cardBgView;
@property (weak, nonatomic) IBOutlet UIImageView *cardNoticeIM;

@end
