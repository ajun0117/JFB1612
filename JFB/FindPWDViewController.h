//
//  FindPWDViewController.h
//  JFB
//
//  Created by LYD on 15/8/25.
//  Copyright (c) 2015年 李俊阳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FindPWDViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *firstL;
@property (weak, nonatomic) IBOutlet UIView *firstView;

@property (weak, nonatomic) IBOutlet UILabel *secondL;
@property (weak, nonatomic) IBOutlet UIView *secondView;

@property (weak, nonatomic) IBOutlet UILabel *thirdL;
@property (weak, nonatomic) IBOutlet UIView *thirdView;


@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;

@property (weak, nonatomic) IBOutlet UILabel *sendToPhoneL;
@property (weak, nonatomic) IBOutlet UIButton *reSendBtn;
@property (weak, nonatomic) IBOutlet UITextField *codeNumTF;
@property (weak, nonatomic) IBOutlet UIButton *checkBtn;

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTF;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end
