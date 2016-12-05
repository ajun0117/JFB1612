//
//  RegisterViewController.h
//  JFB
//
//  Created by 李俊阳 on 15/8/21.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *firstView;

@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UITextField *carAddressTF;
@property (weak, nonatomic) IBOutlet UIButton *radioBtn;

@property (weak, nonatomic) IBOutlet UIButton *reSendBtn;
@property (strong, nonatomic) IBOutlet UIButton *yuyinBtn;
@property (weak, nonatomic) IBOutlet UITextField *codeNumTF;

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTF;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end
